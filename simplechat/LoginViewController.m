#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ChannelsTableViewController.h"
#import "HTTPResourcesManager.h"

@interface LoginViewController ()

@property(nonatomic, strong)UIButton *registerButton;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  self.title = @"Вход";
  
  UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(dismissKeyboard)];
  tapBackground.numberOfTapsRequired = 1;
  [self.view addGestureRecognizer:tapBackground];
  
  [self placeEmailTextFiled];
  [self placePasswordTextFiled];
  [self placeEnterButton];
  [self placeRegisterButton];
  
  [self applyConstrains];
}


-(void)placeEmailTextFiled
{
  self.emailTextField = [UITextField new];
  self.emailTextField.backgroundColor = [UIColor whiteColor];
  self.emailTextField.returnKeyType = UIReturnKeyDone;
  self.emailTextField.delegate = self;
  [self.emailTextField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
  self.emailTextField.translatesAutoresizingMaskIntoConstraints = NO;
  self.emailTextField.layer.borderWidth = 0.5f;
  self.emailTextField.layer.cornerRadius = 3.f;
  self.emailTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.emailTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10.f, 0, 0);
  self.emailTextField.placeholder = @"Почтовый адрес";
  self.emailTextField.font = [UIFont systemFontOfSize:14.f];
  
  [self.view addSubview:self.emailTextField];

}
-(void)placePasswordTextFiled
{
  self.passwordTextField = [UITextField new];
  self.passwordTextField.backgroundColor = [UIColor whiteColor];
  self.passwordTextField.returnKeyType = UIReturnKeyDone;
  self.passwordTextField.delegate = self;
  self.passwordTextField.secureTextEntry = YES;
  [self.passwordTextField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
  self.passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
  self.passwordTextField.layer.borderWidth = 0.5f;
  self.passwordTextField.layer.cornerRadius = 3.f;
  self.passwordTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.passwordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10.f, 0, 0);
  self.passwordTextField.placeholder = @"Пароль";
  self.passwordTextField.font = [UIFont systemFontOfSize:14.f];
  
  [self.view addSubview:self.passwordTextField];

}

-(void)placeEnterButton
{
  self.enterButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.enterButton setTitle:@"Вход" forState:UIControlStateNormal];
  self.enterButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.enterButton addTarget:self action:@selector(enterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  self.enterButton.enabled = NO;
  
  [self.view addSubview:self.enterButton];
}

-(void)placeRegisterButton
{
  self.registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.registerButton setTitle:@"Регистрация" forState:UIControlStateNormal];
  self.registerButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.registerButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
  [self.registerButton addTarget:self action:@selector(registerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:self.registerButton];
}

-(void)applyConstrains
{
  [self.view removeConstraints:self.view.constraints];
  
  id top = self.topLayoutGuide;
  
  NSDictionary *views = NSDictionaryOfVariableBindings(_emailTextField, _passwordTextField, _enterButton, _registerButton, top);
  
  NSString *vertical = @"V:[top]-50-[_emailTextField(_enterButton)]-[_passwordTextField(_enterButton)]-[_enterButton]-50-[_registerButton]";
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vertical options:0 metrics:nil views:views]];

  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_emailTextField
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_passwordTextField
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_registerButton
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_enterButton
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_emailTextField
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_registerButton
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:2.5
                                                         constant:0.0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_passwordTextField
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_registerButton
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:2.5
                                                         constant:0.0]];
}

-(void)enterButtonTapped
{
  _enterButton.enabled = NO;
  _registerButton.enabled = NO;
  
  HTTPResourcesManager *manager = [HTTPResourcesManager manager];
  [manager createSessionForEmail:_emailTextField.text
                     andPassword:_passwordTextField.text
                  withCompletion:^(User *user, NSInteger httpStatusCode)
   {
     _registerButton.enabled = YES;
     [self textFieldDidChange];
     
     switch (httpStatusCode)
     {
       case 201:
       {
         [self textFieldDidChange];
         
         manager.currentUser = user;
         
         ChannelsTableViewController *channelsVC = [ChannelsTableViewController new];
         [self.navigationController pushViewController:channelsVC animated:YES];
         break;
       }
       case 422:
       {
         [[[UIAlertView alloc] initWithTitle:@"Ошибка!"
                                     message:@"Неверный email-адрес и/или пароль."
                                    delegate:self
                           cancelButtonTitle:@"Повторить"
                           otherButtonTitles:nil] show];
         break;
       }
       default:
         break;
     }
   }];
}

-(void)registerButtonTapped
{
  RegisterViewController *regVC = [RegisterViewController new];
  [self.navigationController pushViewController:regVC animated:YES];
}

-(void)dismissKeyboard
{
  [self.view endEditing:YES];
}

-(void)textFieldDidChange
{
  _enterButton.enabled = _emailTextField.text.length && _passwordTextField.text.length;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [self dismissKeyboard];
  return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  _emailTextField.text = @"";
  _passwordTextField.text = @"";
  _enterButton.enabled = NO;
}

@end
