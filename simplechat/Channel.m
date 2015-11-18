#import "Channel.h"

@implementation Channel

-(instancetype)initWithDictionary:(NSDictionary *)dict
{
  self = [super init];
  
  if(self)
  {
    _uid        = [dict[@"id"] integerValue];
    _name       = dict[@"name"];
    _ownerName  = dict[@"owner_name"];
  }
  
  return self;

}

+(NSArray *)itemsFromArray:(NSArray *)array
{
  NSMutableArray *result = [NSMutableArray array];
  
  for (NSDictionary *dict in array) {
    [result addObject:[[Channel alloc]initWithDictionary:dict]];
  }
  
  return result;
}

@end
