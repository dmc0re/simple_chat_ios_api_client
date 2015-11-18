#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate,
                                                  UIAlertViewDelegate>

@property(nonatomic, strong)UITextField *emailTextField;
@property(nonatomic, strong)UITextField *passwordTextField;
@property(nonatomic, strong)UIButton    *enterButton;

@end
