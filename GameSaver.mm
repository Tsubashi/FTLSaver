#import "GameSaver.h"
#import "UIAlertView+Blocks.h"


//Todo list
// * Auto-kill FTL before a restore. 


@implementation GameSaver
-(id) init
{  
  if (self = [super init]) {
    fileManager = [NSFileManager defaultManager];
    
    //------------------------------------------------------------------------
    //Find the App Directory
    /* It would be nice if this worked, but it does not. Too many items.
    {
      NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:@"/var/mobile/Applications"];
      NSString *file;
      BOOL foundIt=NO;
      while ((file = [dirEnum nextObject])) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",savePath,file];
        NSRange range = [filePath rangeOfString:@"FTL.app"]; 
        if (!(range.location == NSNotFound )) {
          NSUInteger max = NSMaxRange(range);
          savePath = [NSString stringWithFormat:@"%@/Library/Application Support/players",[filePath substringWithRange:NSMakeRange(0,max)]];
          foundIt=YES;
          [self alertStuff:[NSString stringWithFormat:@"Game Directory: %@",savePath]];
          break;
        }
      }
      if (!(foundIt)) {
        [self alertStuff:@"Game Directory not found. Is it installed?"];
      }
    } 
    */
    savePath = @"/var/mobile/AppLinks/FTL.app/Library/Application Support/players";
    if (!([fileManager fileExistsAtPath:savePath])) {
      [self alertStuff:@"Game Directory not found. Is it installed?"];
    }
    

    //------------------------------------------------------------------------
    // Determine where the save game files are
    {
      BOOL isDir=NO;
      //List all directories in FTL.app/Library/Application Support/players
      NSMutableArray *UserList = [[NSMutableArray alloc] init];
      NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:savePath];
      NSString *file;
      while ((file = [dirEnum nextObject])) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",savePath,file];
        isDir=NO;
        if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir] && isDir) {
          [UserList addObject:file];
        }
      }
      
      // Determine if we have what we need, or if we need the user to take action.
      if ([UserList count] == 0) { //No users detected
        [self alertStuff:@"No users found. Try playing a game first!"];
        userCode = @"Nobody";
      } else if ([UserList count] > 1) { //Multiple users detected
        [self alertStuff:@"Multiple users found!"];
        for(NSString* user in UserList) {
          [self alertStuff:user];
        }
        userCode = @"Nobody";
      } else { // Only one user detected
        userCode = [UserList firstObject];
      }
      
      //Get documents directory. Create it if it does not exist
      archivePath = @"/var/mobile/Library/FTLsaver/saves";
      isDir=NO;
      if (!([fileManager fileExistsAtPath:archivePath isDirectory:&isDir] && isDir)) {
        if(![fileManager createDirectoryAtPath:archivePath withIntermediateDirectories:YES attributes:nil error:NULL]) {
          [self alertStuff:[NSString stringWithFormat:@"Error: Create folder failed %@", archivePath]];
        }
      }
      
      //Define the save game path
      saveGamePath = [[NSString alloc] initWithFormat:@"%@/%@/continue.sav",savePath,userCode];
    }
  }
  return self;
}

-(void)alertStuff:(NSString*)text
{
  UIAlertView*theAlert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:text delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
  [theAlert show];
  [theAlert release];
}

-(BOOL)stringIsOK:(NSString*)string
{
  NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
  s = [s invertedSet];
  NSRange r = [string rangeOfCharacterFromSet:s];
  return (r.location == NSNotFound);
}

- (void)deleteSavedGame {
  if ([fileManager fileExistsAtPath:saveGamePath]) {
    [fileManager removeItemAtPath:saveGamePath error:NULL];
  }
}
- (void)doSave:(NSString*)name overwrite:(BOOL)shouldOverwrite
{
  if([self stringIsOK:name]) {
    if ([fileManager fileExistsAtPath:saveGamePath]==NO) {
      [self alertStuff:@"No save game found!"];
    } else {
      NSString *archiveSavePath = [NSString stringWithFormat:@"/%@/%@.sav",archivePath,name];
      if ([fileManager fileExistsAtPath:archiveSavePath]) {
        if (shouldOverwrite) {
          [fileManager removeItemAtPath:archiveSavePath error:NULL];
        } else {
          [UIAlertView showWithTitle:@"Warning!"
                    message:@"A savegame by that name already exists. Would you like to overwrite it?"
          cancelButtonTitle:@"Cancel"
          otherButtonTitles:@[@"Overwrite"]
                    tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == [alertView cancelButtonIndex]) {
                            return;
                        }
                    }
          ];
        }
      }
      if ([fileManager copyItemAtPath:saveGamePath toPath:archiveSavePath  error:NULL]) {
	[self alertStuff:@"Saved successfully"];
      } else {
	[self alertStuff:@"Failed to save!"];
      }
    }
  } else {
    [self alertStuff:@"Name can only contain A-Z,0-9, and _ charaters. Please pick a new name."];
  }
}

- (void)doRestore:(NSString*)name {
  if([self stringIsOK:name]) {
    if ([fileManager fileExistsAtPath:saveGamePath]) {
      [UIAlertView showWithTitle:@"Warning!"
                   message:@"A savegame is currently in progress. Are you sure you would like to overwrite? All progress on the current savegame will be lost."
         cancelButtonTitle:@"Cancel"
         otherButtonTitles:@[@"Overwrite"]
                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                      if (buttonIndex == [alertView cancelButtonIndex]) {
                          [self alertStuff:@"Cancelled"];
                      } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Overwrite"]) {
                          [self doRestoreOverwrite:name];
                      }
                  }];
      return;
    } else {
      [self doRestoreOverwrite:name];
    }
  } else {
    [self alertStuff:@"Name can only contain A-Z,0-9, and _ charaters. Please pick a new name."];
  }
}
- (void)doRestoreOverwrite:(NSString*)name {
  //Declare savegamedata
  NSData *saveGameData = nil;
  //Build copy path
  NSString *archiveSavePath = [NSString stringWithFormat:@"/%@/%@.sav",archivePath,name];
  if (!([fileManager fileExistsAtPath:archiveSavePath])) {
    [self alertStuff:@"No savegame exists by that name."];
    return;
  } else {
    saveGameData = [fileManager contentsAtPath:archiveSavePath];
  }
  [self deleteSavedGame];
  if (saveGameData != nil) {
    [saveGameData writeToFile:saveGamePath atomically:YES];
    [self alertStuff:@"Savegame restored!"];
  } else {
    [self alertStuff:@"The save game contained no data!"];
  }
}
@end