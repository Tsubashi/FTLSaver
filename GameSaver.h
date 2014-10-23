#import<UIKit/UIKit.h>

@interface GameSaver : NSObject {
  NSFileManager *fileManager;
  NSString      *savePath;
  NSString      *userCode;
  NSString      *archivePath;
  NSString      *saveGamePath;
}

- (void)doSave:(NSString*)name overwrite:(BOOL)shouldOverwrite;
- (void)doRestore:(NSString*)name;
@end
