#import "RightViewController.h"
#import "LeftViewController.h"

@interface FTLSaverApplication: UIApplication <UIApplicationDelegate> {
  UIWindow *_window;
  UINavigationController *_viewController;
}
@property (nonatomic, retain) UIWindow *window;
@end

@implementation FTLSaverApplication
@synthesize window = _window;
- (void)applicationDidFinishLaunching:(UIApplication *)application {

  //LeftViewController* left   = [[LeftViewController alloc] init];
  RightViewController* right = [[RightViewController alloc] initWithStyle:UITableViewStyleGrouped];
  _viewController = [[UINavigationController alloc] initWithRootViewController:right];
  _viewController.navigationBar.hidden = YES;
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  //_viewController = [[SplitViewController alloc] init];
  //_viewController.viewControllers = [NSArray arrayWithObjects:left, right, nil];
  _viewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"purple_nebula"]];
  _window.rootViewController = _viewController;
  //[_window addSubview:_viewController.view];
  [_window makeKeyAndVisible];

}

- (void)dealloc {
  [_viewController release];
  [_window release];
  [super dealloc];
}
@end

// vim:ft=objc
