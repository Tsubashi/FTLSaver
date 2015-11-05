#import<UIKit/UIKit.h>

@interface GameSaver : NSObject {
  NSFileManager    *fileManager;
  NSString         *savePath;
  NSString         *userCode;
  NSString         *archivePath;
  NSString         *saveGamePath;
  UIViewController *viewControllerForDialogs;
}

-(id) initWithViewController:(UIViewController*)view;
- (BOOL)deleteSaveFile:(NSString*)name;
- (void)doSave:(NSString*)name;
- (void)doSaveOverwrite:(NSString*)name;
- (void)doRestore:(NSString*)name;
- (void)doRestoreOverwrite:(NSString*)name;
@end
