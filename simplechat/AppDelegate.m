#import "AppDelegate.h"
#import "ChannelsTableVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  ChannelsViewController *mainViewController = [ChannelsViewController new];
  
  UINavigationController *navController = [[UINavigationController alloc]
                                           initWithRootViewController:mainViewController];
  
  [[self window] setRootViewController:navController];
  [self.window makeKeyAndVisible];
  
  return YES;
}

@end
