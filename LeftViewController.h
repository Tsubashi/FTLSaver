#import<UIKit/UIKit.h>

@interface LeftViewController: UIViewController {
  UILabel       *helloLabel;
  NSFileManager *fileManager;
  NSString      *savePath;
  NSString      *userCode;
  NSString      *archivePath;
  NSString      *saveGamePath;
}
//-(IBAction)showUserList:(id)sender;
@end
