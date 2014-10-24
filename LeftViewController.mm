#import "LeftViewController.h"

#define TAG_SAVEGAME_NAME 1
#define TAG_RESTOREGAME_NAME 2

@implementation LeftViewController
- (void)loadView 
{
  self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
  self.view.backgroundColor = [UIColor clearColor];
  
  gameSaver = [[GameSaver alloc] init];
  
  //------------------------------------------------------------------------
  // Save Game Button
  UIButton*saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  saveButton.frame = CGRectMake(25, 200, 250, 35);
  saveButton.backgroundColor = [UIColor clearColor];
  [saveButton setTitle:@"Save Current Game by Name" forState:UIControlStateNormal];
  [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:saveButton];
  
  //------------------------------------------------------------------------
  // Restore Game Button
  UIButton*restoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  restoreButton.frame = CGRectMake(25, 250, 250, 35);
  restoreButton.backgroundColor = [UIColor clearColor];
  [restoreButton setTitle:@"Restore a Game by Name" forState:UIControlStateNormal];
  [restoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
  UIAlertView*alert = [[UIAlertView alloc] initWithTitle:@"Save Current Game" message:@"What would you like name this save game?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
  alert.alertViewStyle = UIAlertViewStylePlainTextInput;
  alert.tag = TAG_SAVEGAME_NAME;
  UITextField * alertTextField = [alert textFieldAtIndex:0];
  alertTextField.placeholder = @"Savegame Name";
  [alert show];
  [alert release];
}

-(void)restoreButtonPressed
{
  UIAlertView*alert = [[UIAlertView alloc] initWithTitle:@"Restore Game" message:@"What game would you like to restore?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
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
    [gameSaver doSave:[[alertView textFieldAtIndex:0] text]];
  } else 
  //------------------------------------------------------------------------
  // TAG_RESTOREGAME_NAME
  if (alertView.tag == TAG_RESTOREGAME_NAME && buttonIndex == 1) {
    //Get savegame name and check 
    [gameSaver doRestore:[[alertView textFieldAtIndex:0] text]];
  }
}
@end