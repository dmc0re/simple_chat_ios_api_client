#import "Message.h"

@implementation Message

-(instancetype)initWithDictionary:(NSDictionary *)dict
{
  self = [super init];
  
  if(self)
  {
    _uid        = [dict[@"id"] integerValue];
    _username   = dict[@"user_name"];
    _text       = dict[@"text"];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    
    _date = [dateFormatter dateFromString:dict[@"created_at"]];
  }
  
  return self;
}

+(NSArray *)itemsFromArray:(NSArray *)array
{
  NSMutableArray *result = [NSMutableArray array];
  
  for (NSDictionary *dict in array) {
    [result addObject:[[Message alloc]initWithDictionary:dict]];
  }
  
  return result;
}

@end
