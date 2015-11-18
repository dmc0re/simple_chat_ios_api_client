#import "MessageTableViewCell.h"
#import "ChatViewController.h"
#import "Channel.h"
#import "Message.h"
#import "PaginationData.h"
#import "HTTPResourcesManager.h"

static NSString *CHAT_CELL_ID = @"chatCell";

@interface ChatViewController ()

@property (nonatomic, strong) NSMutableArray  *messages;

@property (nonatomic, strong) UITextField           *textField;
@property (nonatomic, strong) UIButton              *sendButton;
@property (nonatomic, strong) UITableView           *tableView;

@property (nonatomic, strong) MessageTableViewCell  *sizingCell;

@property (nonatomic, strong) PaginationData  *pagination;
@property (nonatomic, assign) BOOL            loadingInProgress;
@property (nonatomic, strong) Message         *beforeMessage; //last mesage item for correct pagination
@property (nonatomic, strong) Message         *newerMessage;

@property (nonatomic, weak) NSTimer           *timer;

@end

@implementation ChatViewController

-(void)viewDidLoad
{
  [super viewDidLoad];
    
  self.view.backgroundColor = [UIColor whiteColor];
  self.title = _channel.name;
  
  self.messages = [NSMutableArray array];
  
  self.sizingCell = [[MessageTableViewCell alloc] initWithReuseIdentifier:nil];
  
  [self placeTextField];
  [self placeSendButton];
  [self placeTableView];
  
  [self addConstrains];
  
  [self.view layoutSubviews];
  
  [self placeLoadingIndicator];
  
  [self loadOldMessages];
}

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  if (self.timer)
    [self startTimer];
}

-(void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  if (self.timer) {
    [self.timer invalidate];
  }
}

-(void)placeTextField
{
  self.textField = [UITextField new];
  self.textField.translatesAutoresizingMaskIntoConstraints = NO;
  self.textField.returnKeyType = UIReturnKeySend;
  self.textField.delegate = self;
  [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
  self.textField.layer.borderWidth = 1.f;
  self.textField.layer.cornerRadius = 3.f;
  self.textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.textField.layer.sublayerTransform = CATransform3DMakeTranslation(10.f, 0, 0);
  
  [self.view addSubview:self.textField];
}

-(void)placeSendButton
{
  self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.sendButton setTitle:@"Отправить" forState:UIControlStateNormal];
  self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.sendButton.enabled = NO;
  [self.sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:self.sendButton];
}

-(void)placeTableView
{
  self.tableView = [UITableView new];
  self.tableView.backgroundColor = [UIColor whiteColor];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
  self.tableView.allowsSelection = NO;
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  
  UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(dismissKeyboard)];
  tapBackground.numberOfTapsRequired = 1;
  [self.tableView addGestureRecognizer:tapBackground];
    
  [self.view addSubview:self.tableView];
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

-(void)addConstrains
{
  id top = self.topLayoutGuide;
  id bottom = self.bottomLayoutGuide;
  
  NSDictionary *views = NSDictionaryOfVariableBindings(_textField, _sendButton, _tableView, top, bottom);
  
  NSString *horizontal = @"H:|-[_textField]-[_sendButton]-|";
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontal options:0 metrics:nil views:views]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:views]];
  
  
  NSString *vertical = @"V:[top]-[_sendButton]-[_tableView][bottom]";
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vertical options:0 metrics:nil views:views]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-[_textField(_sendButton)]" options:0 metrics:nil views:views]];
}

-(void)loadNewMessages
{
  HTTPResourcesManager *manager = [HTTPResourcesManager manager];
  [manager getMessagesNewerThan:_newerMessage
                     forChannel:_channel
                 withCompletion:^(NSArray *messages, NSInteger httpStatusCode)
  {
    if (httpStatusCode == 200)
    {
      [_messages insertObjects:messages
                     atIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, messages.count)]];
      if (messages.count) {
        [_tableView reloadData];
      }
    }
    [self startTimer];
  }];
}

-(void)startTimer
{
  if (_messages.count) {
    _newerMessage = _messages.firstObject;
  }
  self.timer = [NSTimer scheduledTimerWithTimeInterval:2
                                                target:self
                                              selector:@selector(loadNewMessages)
                                              userInfo:nil
                                               repeats:NO];
}

-(void)loadOldMessages
{
  _loadingInProgress = YES;
  
  HTTPResourcesManager *manager = [HTTPResourcesManager manager];
  [manager getMessagesIndexForPageNum:self.pagination ? self.pagination.currentPage + 1 : 1
                        beforeMessage:_beforeMessage andChannel:_channel
                       withCompletion:^(NSArray *messages, PaginationData *pagination, NSInteger httpStatusCode)
  {
    if (httpStatusCode == 200)
    {
      if (!_beforeMessage)
        self.beforeMessage = messages.firstObject;
      
      self.pagination = pagination;
      
      [self.messages addObjectsFromArray:messages];
      [self.tableView reloadData];
    }
    
    [self removeLoadingIndicator];
    _loadingInProgress = NO;
	
    if (!self.timer)
      [self startTimer];
  }];
}

-(void)loadNextPageIfExist
{
  if (self.pagination && !_loadingInProgress)
  {
    if (self.pagination.currentPage != self.pagination.totalPages) {
      [self placeLoadingIndicator];
      [self loadOldMessages];
    }
  }
}

-(void)sendButtonTapped
{
  [_textField endEditing:YES];
  
  _textField.enabled = NO;
  _sendButton.enabled = NO;
  [_sendButton setTitle:@"Отправка..." forState:UIControlStateNormal];
  
  HTTPResourcesManager *manager = [HTTPResourcesManager manager];
  [manager createMessageForChannel:_channel
                              andText:_textField.text
                       withCompletion:^(Message *message, NSInteger httpStatusCode)
   {
     if (httpStatusCode == 201) {
       _textField.text = @"";
       _textField.enabled = YES;
       _sendButton.enabled = YES;
       [_sendButton setTitle:@"Отправить" forState:UIControlStateNormal];
       [_tableView setContentOffset:CGPointZero animated:YES];
     }
   }];
}

-(void)dismissKeyboard
{
  [_textField endEditing:YES];
}

-(void)textFieldDidChange:(UITextField *)textField
{
  self.sendButton.enabled = (BOOL)textField.text.length;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField.text.length)
  {
    [self sendButtonTapped];
    return YES;
  }
 
  return false;
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CHAT_CELL_ID];
  
  if (cell == nil) {
    cell = [[MessageTableViewCell alloc] initWithReuseIdentifier:CHAT_CELL_ID];
  }
  
  Message *message = self.messages[indexPath.row];
  
  cell.message = message;
  
  if ((_messages.count - 5) < indexPath.row)
    [self loadNextPageIfExist];
  
  return cell;
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  self.sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 0);
  
  Message *message = _messages[indexPath.row];
  
  CGFloat calculatedHeight = 0;
  
  self.sizingCell.message = message;
  
  [self.sizingCell setNeedsLayout];
  [self.sizingCell layoutIfNeeded];
  
  calculatedHeight = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
  
  return calculatedHeight;
}
@end
