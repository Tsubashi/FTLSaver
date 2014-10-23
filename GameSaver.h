#import<UIKit/UIKit.h>

@interface GameSaver : NSObject {
  NSFileManager *fileManager;
  NSString      *savePath;
  NSString      *userCode;
  NSString      *archivePath;
  NSString      *saveGamePath;
}
@end
