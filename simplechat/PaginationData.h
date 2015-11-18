#import <Foundation/Foundation.h>

@interface PaginationData : NSObject

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger totalCount;

-(instancetype)initWithDictionary:(NSDictionary *)dict;

@end
