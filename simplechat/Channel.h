#import <Foundation/Foundation.h>

@interface Channel : NSObject

@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy)   NSString  *name;
@property (nonatomic, copy)   NSString  *ownerName;


-(instancetype)initWithDictionary:(NSDictionary *)dict;
+(NSArray *)itemsFromArray:(NSArray *)array;

@end
