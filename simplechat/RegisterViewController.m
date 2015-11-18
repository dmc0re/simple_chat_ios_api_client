#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "HTTPResourcesManager.h"

@interface RegisterViewController ()

@property(nonatomic, strong)UITextField *nameTextField;
@property(nonatomic, strong)UITextField *emailTextField;
@property(nonatomic, strong)UITextField *passwordTextField;
@property(nonatomic, strong)UITextField *confirmPasswordTextField;
@property(nonatomic, strong)UIButton    *registerButton;

@property(nonatomic, assign)BOOL        registrationCompletedFlag;

@end

@implementation RegisterViewController

-(void)viewDidLoad
{
  [super viewDidLoad];
 
  self.view.backgroundColor = [UIColor whiteColor];
  self.title = @"Регистрация";
  
  UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(dismissKeyboard)];
  tapBackground.numberOfTapsRequired = 1;
  [self.view addGestureRecognizer:tapBackground];
  
  [self placeTextFields];
  [self placeRegisterButton];
  
  [self applyConstrains];
}

-(void)placeTextFields
{
  self.nameTextField = [UITextField new];
  self.nameTextField.placeholder = @"Имя пользователя";
  
  self.emailTextField = [UITextField new];
  self.emailTextField.placeholder = @"Почтовый адрес";

  self.passwordTextField = [UITextField new];
  self.passwordTextField.placeholder = @"Пароль";
  self.passwordTextField.secureTextEntry = YES;
  
  self.confirmPasswordTextField  = [UITextField new];
  self.confirmPasswordTextField.placeholder = @"Подтверждение пароля";
  self.confirmPasswordTextField.secureTextEntry = YES;
  
  for (UITextField *field in @[_nameTextField,
                               _emailTextField,
                               _passwordTextField,
                               _confirmPasswordTextField])
  {
    field.backgroundColor = [UIColor whiteColor];
    field.returnKeyType = UIReturnKeyDone;
    field.delegate = self;
    [field addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    field.translatesAutoresizingMaskIntoConstraints = NO;
    field.layer.borderWidth = 0.5f;
    field.layer.cornerRadius = 3.f;
    field.layer.borderColor = [UIColor lightGrayColor].CGColor;
    field.layer.sublayerTransform = CATransform3DMakeTranslation(10.f, 0, 0);
    field.font = [UIFont systemFontOfSize:14.f];
    
    [self.view addSubview:field];
  }
}

-(void)placeRegisterButton
{
  self.registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.registerButton setTitle:@"Зарегистрироваться" forState:UIControlStateNormal];
  self.registerButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.registerButton addTarget:self action:@selector(registerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  self.registerButton.enabled = NO;
  
  [self.view addSubview:self.registerButton];
}

-(void)applyConstrains
{
  [self.view removeConstraints:self.view.constraints];
  
  id top = self.topLayoutGuide;
  
  NSDictionary *views = NSDictionaryOfVariableBindings(_nameTextField, _emailTextField, _passwordTextField,
                                                       _confirmPasswordTextField, _registerButton, top);
  
  NSString *vertical = @"V:[top]-50-[_nameTextField(_registerButton)]-[_emailTextField(_registerButton)]-"
  @"[_passwordTextField(_registerButton)]-[_confirmPasswordTextField(_registerButton)]-[_registerButton]";
  
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vertical options:0 metrics:nil views:views]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_nameTextField
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
  
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
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_confirmPasswordTextField
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
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_nameTextField
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_registerButton
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.5
                                                         constant:0.0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_emailTextField
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_registerButton
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.5
                                                         constant:0.0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_passwordTextField
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_registerButton
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.5
                                                         constant:0.0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_confirmPasswordTextField
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_registerButton
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.5
                                                         constant:0.0]];
}

-(void)registrationProc
{
  HTTPResourcesManager *manager = [HTTPResourcesManager manager];
  [manager createUserWithEmail:_emailTextField.text
                       andName:_nameTextField.text
                   andPassword:_passwordTextField.text
                withCompletion:^(User *user, NSInteger httpStatusCode)
  {
    switch (httpStatusCode) {
      case 201:
      {
        _registrationCompletedFlag = YES;
        [self showAlertViewWithTitle:@"" andMessage:@"Регистрация прошла успешно."];
         break;
      }
      case 422:
      {
        [self showAlertViewWithTitle:@"Ошибка!" andMessage:@"Пользователь с таким именем или/и "
                                                @"email-адресом уже существуют\n попробуйте ввести другие."];
        break;
      }
      default:
        break;
    }
  }];
}

-(void)registerButtonTapped
{
  if (![self validateEmailWithString:_emailTextField.text]) {
    [self showAlertViewWithTitle:@"Ошибка!" andMessage:@"Неверный формат email-адреса."];
  }
  else {
    if ([_passwordTextField.text isEqualToString:_confirmPasswordTextField.text]) {
      if (_passwordTextField.text.length > 7) {
        [self registrationProc];
      }
      else
      {
        [self showAlertViewWithTitle:@"Ошибка!" andMessage:@"Пароль слишком короткий (минимум 8 символов)"];
        [self clearPasswordFields];
      }
    }
    else
    {
      [self showAlertViewWithTitle:@"Ошибка!" andMessage:@"Введенные пароли не совпадают."];
      [self clearPasswordFields];
    }
  }
}

-(void)dismissKeyboard
{
  [self.view endEditing:YES];
}

-(void)textFieldDidChange
{
  _registerButton.enabled = _nameTextField.text.length && _emailTextField.text.length &&
                            _passwordTextField.text.length && _confirmPasswordTextField.text.length;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [self dismissKeyboard];
  return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (_registrationCompletedFlag)
  {
    UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    LoginViewController *loginVC = (LoginViewController *)vc;
    loginVC.emailTextField.text = _emailTextField.text;
    loginVC.passwordTextField.text = _passwordTextField.text;
    loginVC.enterButton.enabled = YES;
    
    [self.navigationController popViewControllerAnimated:YES];
  }
}

-(void)clearPasswordFields
{
  _passwordTextField.text = @"";
  _confirmPasswordTextField.text = @"";
  _registerButton.enabled = NO;
}

-(void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message
{
  [[[UIAlertView alloc] initWithTitle:title
                              message:message
                             delegate:self
                    cancelButtonTitle:@"Ок"
                    otherButtonTitles:nil] show];
}

-(BOOL)validateEmailWithString:(NSString*)email
{
  NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
  NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
  return [emailTest evaluateWithObject:email];
}


@end
