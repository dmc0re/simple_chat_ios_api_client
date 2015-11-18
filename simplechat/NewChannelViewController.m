#import "NewChannelViewController.h"
#import "ChannelsTableViewController.h"
#import "HTTPResourcesManager.h"

@interface NewChannelViewController ()

@property (nonatomic, strong) UILabel     *infoLabel;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UIButton    *addButton;

@end

@implementation NewChannelViewController

-(void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(dismissKeyboard)];
  tapBackground.numberOfTapsRequired = 1;
  [self.view addGestureRecognizer:tapBackground];
  
  [self placeInfoLabel];
  [self placeNameTextField];
  [self placeAddButton];
  
  [self applyConstrains];
}

-(void)placeInfoLabel
{
  self.infoLabel = [UILabel new];
  self.infoLabel.text = @"Введите имя нового канала";
  self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
  
  [self.view addSubview:self.infoLabel];
}

-(void)placeNameTextField
{
  self.nameTextField = [UITextField new];
  self.nameTextField.backgroundColor = [UIColor whiteColor];
  self.nameTextField.returnKeyType = UIReturnKeyDone;
  self.nameTextField.delegate = self;
  [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
  self.nameTextField.translatesAutoresizingMaskIntoConstraints = NO;
  self.nameTextField.layer.borderWidth = 0.5f;
  self.nameTextField.layer.cornerRadius = 3.f;
  self.nameTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.nameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10.f, 0, 0);
  
  [self.view addSubview:self.nameTextField];
}

-(void)placeAddButton
{
  self.addButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.addButton setTitle:@"Добавить" forState:UIControlStateNormal];
  self.addButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.addButton.enabled = NO;
  [self.addButton addTarget:self action:@selector(addButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:self.addButton];
}

-(void)applyConstrains
{
  [self.view removeConstraints:self.view.constraints];
  
  id top = self.topLayoutGuide;
  
  NSDictionary *views = NSDictionaryOfVariableBindings(_infoLabel, _nameTextField, _addButton, top);
  
  NSString *vertical = @"V:[top]-[_infoLabel]-[_nameTextField(_addButton)]-[_addButton]";
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vertical options:0 metrics:nil views:views]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_infoLabel
                                                         attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_nameTextField
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_addButton
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_addButton
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_infoLabel
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:0.0]];
  
   [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_nameTextField
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_infoLabel
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0.0]];
}

-(void)addButtonTapped
{
  HTTPResourcesManager *manager = [HTTPResourcesManager manager];
  [manager createNewChannelWithName:_nameTextField.text
                     withCompletion:^(Channel *channel, NSInteger httpStatusCode)
  {
    switch (httpStatusCode) {
      case 201:
      {
        UIViewController *prevVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
        ChannelsTableViewController *channelsVC = (ChannelsTableViewController*) prevVC;
        [channelsVC.channels insertObject:channel atIndex:0];
        [channelsVC.tableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
        break;
      }
      case 422:
      {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"Ошибка! Канал с таким именем уже существует!"
                                   delegate:nil
                          cancelButtonTitle:@"Ок"
                          otherButtonTitles:nil] show];
        break;
      }
      default:
        break;
    }
  }];
}

-(void)dismissKeyboard
{
  [_nameTextField endEditing:YES];
}

-(void)textFieldDidChange:(UITextField *)textField
{
  self.addButton.enabled = (BOOL)textField.text.length;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField endEditing:YES];
  return YES;
}

@end
