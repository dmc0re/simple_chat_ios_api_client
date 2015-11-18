#import "MessageTableViewCell.h"
#import "Message.h"
#import "NSDate+TimeAgo.h"
#import "Label.h"

@interface MessageTableViewCell()

@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UILabel *dataTimeLabel;
@property(nonatomic, strong)UILabel *messageTextLabel;

@end

@implementation MessageTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier
{
  self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
  if (self)
  {
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self placeNameLabel];
    [self placeDateTimeLabel];
    [self placeMessageTextLabel];
    
    [self applyConstrains];
  }
  return self;
}

-(void)placeNameLabel
{
  self.nameLabel = [UILabel new];
  self.nameLabel.font = [UIFont boldSystemFontOfSize:15.f];
  self.nameLabel.textColor = [UIColor blackColor];
  self.nameLabel.backgroundColor = [UIColor whiteColor];
  self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
  
  [self.contentView addSubview:self.self.nameLabel];
}

-(void)placeDateTimeLabel
{
  self.dataTimeLabel = [UILabel new];
  self.dataTimeLabel.font = [UIFont systemFontOfSize:12.f];
  self.dataTimeLabel.textColor = [UIColor lightGrayColor];
  self.dataTimeLabel.textAlignment = NSTextAlignmentRight;
  self.dataTimeLabel.backgroundColor = [UIColor whiteColor];
  self.dataTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
  
  [self.contentView addSubview:self.dataTimeLabel];
}

-(void)placeMessageTextLabel
{
  self.messageTextLabel = [Label new];
  self.messageTextLabel.font = [UIFont systemFontOfSize:15.f];
  self.messageTextLabel.textColor = [UIColor darkGrayColor];
  self.messageTextLabel.numberOfLines = 0;
  self.messageTextLabel.backgroundColor = [UIColor whiteColor];
  self.messageTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
  
  [self.contentView addSubview:self.messageTextLabel];
}

-(void)setMessage:(Message *)message
{
  _message = message;
  
  _nameLabel.text = message.username;
  _messageTextLabel.text = message.text;
  _dataTimeLabel.text = message.date.timeAgo;
  
  [self setNeedsUpdateConstraints];
  [self setNeedsLayout];
}

-(void)applyConstrains
{
  [self.contentView removeConstraints:self.contentView.constraints];
  
  
  [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.contentView
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1
                                                                constant:10.f]];
  
  [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.contentView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:10.f]];
  
  [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_messageTextLabel
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.contentView
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1
                                                                constant:10.f]];
  
  [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_messageTextLabel
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_nameLabel
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1
                                                                constant:0]];
  
  [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_messageTextLabel
                                                               attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.contentView
                                                               attribute:NSLayoutAttributeRight
                                                              multiplier:1
                                                                constant:-10.f]];
  
  
  [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                               attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_dataTimeLabel
                                                               attribute:NSLayoutAttributeRight
                                                              multiplier:1
                                                                constant:10.f]];
  
  NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:_dataTimeLabel
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                  toItem:_messageTextLabel
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1
                                                                constant:0];
  c.priority = UILayoutPriorityDefaultHigh;
  [self.contentView addConstraint:c];
  
  [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_dataTimeLabel
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1
                                                                constant:10.f]];
}

-(void)updateConstraints
{
  [super updateConstraints];
}

@end
