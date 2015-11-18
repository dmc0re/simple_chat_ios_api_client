#import "AppDelegate.h"
#import "LoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  LoginViewController *mainViewController = [LoginViewController new];
  
  UINavigationController *navController = [[UINavigationController alloc]
                                           initWithRootViewController:mainViewController];
  
  [[self window] setRootViewController:navController];
  [self.window makeKeyAndVisible];
  
  return YES;
}

@end
