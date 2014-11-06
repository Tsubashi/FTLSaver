#import "GameSaver.h"
#import "UIBAlertView.h"


NSArray *findAppContainersWithName(NSString *name) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *containers = [[NSMutableArray alloc] init];
    NSString *app = [name stringByAppendingString:@".app"];
    NSString *apps_path = @"/var/mobile/Applications";
    
    if([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
      [apps_path release];
      apps_path = @"/var/mobile/Containers/Data/Application";
    } 
    
    for(NSString *appContainer in [fileManager contentsOfDirectoryAtPath:apps_path error:nil]) {
        NSString *appContainerPath = [apps_path stringByAppendingPathComponent:appContainer];
        if([fileManager fileExistsAtPath:[appContainerPath stringByAppendingPathComponent:app]]) {
            [containers addObject:appContainerPath];
        }
    }

    return containers;
}

NSString *findAppContainer(NSString *name, NSString *bundleID) {
    NSArray *appContainers = findAppContainersWithName(name);
    NSString *app = [name stringByAppendingString:@".app"];
    for(NSString *appContainer in appContainers) {
        NSBundle *bundle = [NSBundle bundleWithPath:[appContainer stringByAppendingPathComponent:app]];
        if([[bundle bundleIdentifier] isEqualToString:bundleID]) {
            return appContainer;
        }
    }
    return nil;
}
//Todo list
// * Auto-kill FTL before a restore. 


@implementation GameSaver
-(id) init
{  
  if (self = [super init]) {
    fileManager = [NSFileManager defaultManager];
    
    //------------------------------------------------------------------------
    //Find the App Directory
    savePath = [[NSString alloc] initWithFormat:@"%@/Library/Application Support/players",findAppContainer(@"FTL", @"com.ftlgame.FTL")];
    if (!([fileManager fileExistsAtPath:savePath])) {
      [self alertStuff:@"Game Directory not found. Is it installed?"];
      [self release];
      return nil;
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
        [self release];
        return nil;
      } else if ([UserList count] > 1) { //Multiple users detected
        [self alertStuff:@"Multiple users found! Not sure what to do..."];
        //for(NSString* user in UserList) {
        //  [self alertStuff:user];
        //}
        [self release];
        return nil;
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
  NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_."];
  s = [s invertedSet];
  NSRange r = [string rangeOfCharacterFromSet:s];
  return (r.location == NSNotFound);
}

- (void)deleteSavedGame {
  if ([fileManager fileExistsAtPath:saveGamePath]) {
    [fileManager removeItemAtPath:saveGamePath error:NULL];
  }
}
- (BOOL)deleteSaveFile:(NSString*)name
{
  NSString* path = [[NSString alloc] initWithFormat:@"%@/%@",archivePath,[self checkExtention:name]];
  if ([fileManager fileExistsAtPath:path]) {
    return [fileManager removeItemAtPath:path error:NULL];
  }
  return YES;
}
- (NSString*)checkExtention:(NSString*)name
{
  if ([[name pathExtension] isEqualToString:@"sav"]) {
    return name;
  } else {
    return [[NSString alloc] initWithFormat:@"%@.sav",name];
  }
}
- (void)doSave:(NSString*)name 
{
  if([self stringIsOK:name]) {
    if ([fileManager fileExistsAtPath:saveGamePath]==NO) {
      [self alertStuff:@"No save game found!"];
    } else {
      NSString *archiveSavePath = [NSString stringWithFormat:@"%@/%@",archivePath,[self checkExtention:name]];
      if ([fileManager fileExistsAtPath:archiveSavePath]) {
        UIBAlertView *alert =[[UIBAlertView alloc] initWithTitle:@"Warning!" 
            message:@"A savegame by that name already exists. Would you like to overwrite it?"
            cancelButtonTitle:@"Cancel"
            otherButtonTitles:@"Overwrite",nil
          ];
        [alert showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
          if (!didCancel) {
            [self doSaveOverwrite:name];
          }
        }];
      } else {
        [self doSaveOverwrite:name];
      }
    }
  } else {
    [self alertStuff:@"Name can only contain A-Z,0-9, and _ charaters. Please pick a new name."];
  }
}

- (void)doSaveOverwrite:(NSString*)name 
{
  NSString *archiveSavePath = [NSString stringWithFormat:@"%@/%@",archivePath,[self checkExtention:name]];
  if ([fileManager fileExistsAtPath:archiveSavePath]) {
    [fileManager removeItemAtPath:archiveSavePath error:NULL];
  }
  if ([fileManager copyItemAtPath:saveGamePath toPath:archiveSavePath  error:NULL]) {
    [self alertStuff:@"Saved successfully"];
  } else {
    [self alertStuff:@"Failed to save!"];
  }
}

- (void)doRestore:(NSString*)name {
  if([self stringIsOK:name]) {
    if ([fileManager fileExistsAtPath:saveGamePath]) {
       UIBAlertView *alert =[[UIBAlertView alloc] initWithTitle:@"Warning!" 
              message:@"A savegame is currently in progress. Are you sure you would like to overwrite? All progress on the current savegame will be lost."
              cancelButtonTitle:@"Cancel"
              otherButtonTitles:@"Overwrite",nil
            ];
          [alert showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
            if (!didCancel) {
              [self doRestoreOverwrite:name];
            }
          }];
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
  NSString *archiveSavePath = [NSString stringWithFormat:@"%@/%@",archivePath,[self checkExtention:name]];
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