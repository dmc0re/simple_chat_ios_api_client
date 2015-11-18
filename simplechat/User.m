#import "User.h"

@implementation User

-(instancetype)initWithDictionary:(NSDictionary *)dict
{
  self = [super init];
  
  if(self)
  {
    _uid          = [dict[@"id"] integerValue];
    _email        = dict[@"email"];
    _authToken    = dict[@"auth_token"];
  }
  
  return self;
  
}

@end
