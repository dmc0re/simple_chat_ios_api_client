#import <UIKit/UIKit.h>

@class Message;

@interface MessageTableViewCell : UITableViewCell

-(instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@property(nonatomic, strong)Message *message;

@end
