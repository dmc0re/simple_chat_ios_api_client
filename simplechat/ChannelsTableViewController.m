#import "ChannelsTableViewController.h"
#import "ChatViewController.h"
#import "HTTPResourcesManager.h"
#import "NewChannelViewController.h"

#import "PaginationData.h"
#import "Channel.h"

@interface ChannelsTableViewController ()

@property (nonatomic, strong) PaginationData  *pagination;
@property (nonatomic, strong) Channel         *beforeChannel; //last channel item for correct pagination
@property (nonatomic, assign) BOOL            loadingInProgress;
@property (nonatomic, strong) UIBarButtonItem *addChannelButton;

@end

@implementation ChannelsTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  self.clearsSelectionOnViewWillAppear = YES;
  self.title = @"Каналы";
  
  self.addChannelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                        target:self
                                                                        action:@selector(addChannelButtonTapped)];
  self.navigationItem.rightBarButtonItem = self.addChannelButton;
  
  self.channels = [NSMutableArray array];
  
  [self placeRefreshControl];
  [self placeLoadingIndicator];
  
  [self pullToRefresh];
}

-(void)loadChannels
{
  _loadingInProgress = YES;
  self.addChannelButton.enabled = NO;
  
  if (self.refreshControl.refreshing)
  {
    self.pagination = nil;
    self.beforeChannel = nil;
  }
  
  HTTPResourcesManager *manager = [HTTPResourcesManager manager];
  [manager getChannelsIndexForPageNum:self.pagination ? self.pagination.currentPage + 1 : 1
                     beforeChannel:_beforeChannel
                       withCompletion:^(NSArray *channels, PaginationData *pagination, NSInteger httpStatusCode)
   {
     if (httpStatusCode == 200)
     {
       if (!_beforeChannel)
         self.beforeChannel = channels.firstObject;
       
       self.pagination = pagination;
       
       if (self.refreshControl.refreshing) {
         [self.channels removeAllObjects];
       }
       [self.channels addObjectsFromArray:channels];
       [self.tableView reloadData];
     }
     
     if (self.refreshControl.refreshing) {
       [self.refreshControl endRefreshing];
     }
     [self removeLoadingIndicator];
     self.tableView.scrollEnabled = YES;
     self.addChannelButton.enabled = YES;
     _loadingInProgress = NO;
   }];
}

-(void)placeRefreshControl
{
  UIRefreshControl *refreshControl = [UIRefreshControl new];
  [refreshControl addTarget:self
                     action:@selector(pullToRefresh)
           forControlEvents:UIControlEventValueChanged];
  
  self.refreshControl = refreshControl;
}

-(void)placeLoadingIndicator
{
  UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  self.tableView.tableFooterView = loadingIndicator;
  [loadingIndicator startAnimating];
}

-(void)removeLoadingIndicator
{
  self.tableView.tableFooterView = nil;
}

-(void)pullToRefresh
{
  if (!_loadingInProgress)
  {
    self.tableView.scrollEnabled = NO;
    [self loadChannels];
  } else {
    [self.refreshControl endRefreshing];
  }
}

-(void)addChannelButtonTapped
{
  NewChannelViewController *newChannelVC = [NewChannelViewController new];
  [self.navigationController pushViewController:newChannelVC animated:YES];
}

-(void)loadNextPageIfExist
{
  if (self.pagination && !_loadingInProgress)
  {
    if (self.pagination.currentPage != self.pagination.totalPages) {
      [self placeLoadingIndicator];
      [self loadChannels];
    }
  }
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _channels.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellIdentifier = @"channelCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if(!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
  }

  Channel *channel = _channels[indexPath.row];
  cell.textLabel.text = channel.name;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"Создатель: %@", channel.ownerName];
  
  if ((_channels.count - 5) < indexPath.row)
    [self loadNextPageIfExist];
  
  return cell;
}



 #pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  Channel *channel = _channels[indexPath.row];
  ChatViewController *chatVC = [ChatViewController new];
  chatVC.channel = channel;
  [self.navigationController pushViewController:chatVC animated:YES];
}



@end
