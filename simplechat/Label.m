#import "Label.h"

@implementation Label

- (id)init {
  self = [super init];
  
  // required to prevent Auto Layout from compressing the label (by 1 point usually) for certain constraint solutions
  [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                        forAxis:UILayoutConstraintAxisVertical];

  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
		
  self.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds);
  
  [super layoutSubviews];
}

@end
