#import "RightViewController.h"
#import "LeftViewController.h"

@interface FTLSaverApplication: UIApplication <UIApplicationDelegate> {
  UIWindow *_window;
  UIViewController *_viewController;
}
@property (nonatomic, retain) UIWindow *window;
@end

@implementation FTLSaverApplication
@synthesize window = _window;
- (void)applicationDidFinishLaunching:(UIApplication *)application {

  LeftViewController* left   = [[LeftViewController alloc] init];
  RightViewController* right = [[RightViewController alloc] initWithStyle:UITableViewStyleGrouped];
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    _viewController = [[UISplitViewController alloc] init];
    ((UISplitViewController *)_viewController).viewControllers = [NSArray arrayWithObjects:left, right, nil];
  } else {
    _viewController = [[UINavigationController alloc] initWithRootViewController:right];
    ((UINavigationController *)_viewController).navigationBar.hidden = YES;
  }
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
