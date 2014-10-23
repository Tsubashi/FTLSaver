#import "LeftViewController.h"

#define TAG_SAVEGAME_NAME 1
#define TAG_RESTOREGAME_NAME 2
#define TAG_RESTOREGAME_OVERWRITE 3

//Todo list
// * Fix overwite confirm. 
// * Create a list view and have the user select saved games based on that. 
// * Auto-kill FTL. 


@implementation LeftViewController
- (void)loadView 
{
  self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
  self.view.backgroundColor = [UIColor whiteColor];
  
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
        return;
      }
    }
    
    //Define the save game path
    saveGamePath = [[NSString alloc] initWithFormat:@"%@/%@/continue.sav",savePath,userCode];
  }
  
  
  //------------------------------------------------------------------------
  // Save Game Button
  UIButton*saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  saveButton.frame = CGRectMake(110, 200, 150, 35);
  [saveButton setTitle:@"Save Current Game" forState:UIControlStateNormal];
  [saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:saveButton];
  
  //------------------------------------------------------------------------
  // Restore Game Button
  UIButton*restoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  restoreButton.frame = CGRectMake(110, 250, 150, 35);
  [restoreButton setTitle:@"Restore a Game" forState:UIControlStateNormal];
  [restoreButton addTarget:self action:@selector(restoreButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:restoreButton];

}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

-(BOOL)shouldAutorotate
{
    return YES;
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

-(void)saveButtonPressed
{
  if ([fileManager fileExistsAtPath:saveGamePath]==NO) {
    [self alertStuff:@"No save game found!"];
  } else {
    UIAlertView*alert = [[UIAlertView alloc] initWithTitle:@"Save Current Game" message:@"What would you like name this save game?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = TAG_SAVEGAME_NAME;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.placeholder = @"Savegame Name";
    [alert show];
    [alert release];
  }
}

-(void)restoreButtonPressed
{
  UIAlertView*alert = [[UIAlertView alloc] initWithTitle:@"Save Current Game" message:@"What game would you like to restore?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
  alert.alertViewStyle = UIAlertViewStylePlainTextInput;
  alert.tag = TAG_RESTOREGAME_NAME;
  UITextField * alertTextField = [alert textFieldAtIndex:0];
  alertTextField.placeholder = @"Savegame Name";
  [alert show];
  [alert release];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
  //------------------------------------------------------------------------
  // TAG_SAVEGAME_NAME
  if(alertView.tag == TAG_SAVEGAME_NAME && buttonIndex == 1) {
    //Get new name from user
    [self doSave:[[alertView textFieldAtIndex:0] text]];
  } else 
  //------------------------------------------------------------------------
  // TAG_RESTOREGAME_NAME
  if (alertView.tag == TAG_RESTOREGAME_NAME && buttonIndex == 1) {
    //Get savegame name and check 
    [self doRestore:[[alertView textFieldAtIndex:0] text]];
  } else
  //------------------------------------------------------------------------
  // TAG_RESTOREGAME_OVERWRITE
  if (alertView.tag == TAG_RESTOREGAME_OVERWRITE && buttonIndex == 1) {
    //TODO: eventually, it would be nice to be able to just call doRestoreOverwrite, if we can ever figure out how to pass the name variable into this function...
    [self deleteSavedGame];
    [self restoreButtonPressed];
  }
}
- (void)deleteSavedGame {
  if ([fileManager fileExistsAtPath:saveGamePath]) {
    [fileManager removeItemAtPath:saveGamePath error:NULL];
  }
}
- (void)doSave:(NSString*)name {
  if([self stringIsOK:name]) {
    NSString *archiveSavePath = [NSString stringWithFormat:@"/%@/%@.sav",archivePath,name];
    if ([fileManager fileExistsAtPath:archiveSavePath]) {
      //[self alertStuff:@"A savegame already exists by that name. Deleting it first."];
      [fileManager removeItemAtPath:archiveSavePath error:NULL];
    }
    if ([fileManager copyItemAtPath:saveGamePath toPath:archiveSavePath  error:NULL]) {
      [self alertStuff:@"Copied successfully"];
    } else {
      [self alertStuff:@"Copy Failed!"];
    }
  } else {
    [self alertStuff:@"Name can only contain A-Z,0-9, and _ charaters. Please pick a new name."];
  }
}

- (void)doRestore:(NSString*)name {
  if([self stringIsOK:name]) {
    if ([fileManager fileExistsAtPath:saveGamePath]) {
      UIAlertView*theAlert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"A savegame is currently in progress. Are you sure you would like to overwrite? All progress on the current savegame will be lost." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
      theAlert.tag = TAG_RESTOREGAME_OVERWRITE;
      [theAlert show];
      [theAlert release];
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