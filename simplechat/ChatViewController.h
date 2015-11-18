#import <UIKit/UIKit.h>

@class Channel;

@interface ChatViewController : UIViewController<UITextFieldDelegate,
                                                UITableViewDataSource,
                                                UITableViewDelegate>

@property (nonatomic, strong) Channel *channel;

@end
