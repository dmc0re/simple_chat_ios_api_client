#import "PaginationData.h"

@implementation PaginationData

-(instancetype)initWithDictionary:(NSDictionary *)dict
{
  self = [super init];
  
  if(self)
  {
    NSDictionary *pagination = dict[@"pagination"];
    
    _currentPage  = [pagination[@"current_page"] integerValue];
    _totalPages   = [pagination[@"total_pages"] integerValue];
    _totalCount   = [pagination[@"total_count"] integerValue];
  }
  
  return self;
}

@end
