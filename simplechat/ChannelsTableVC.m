#import "ChannelsTableVC.h"

@interface ChannelsViewController ()

@end

@implementation ChannelsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  self.view.backgroundColor = [UIColor whiteColor];
  [self placeRefreshControl];
}

-(void)placeRefreshControl
{
  UIRefreshControl *refreshControl = [UIRefreshControl new];
  [refreshControl addTarget:self
                     action:@selector(pullToRefresh)
           forControlEvents:UIControlEventValueChanged];
  
  self.refreshControl = refreshControl;
}

-(void)pullToRefresh
{
  //to be implemented in descendants
}

@end
