#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy)   NSString  *username;
@property (nonatomic, copy)   NSString  *text;
@property (nonatomic, strong) NSDate    *date;

-(instancetype)initWithDictionary:(NSDictionary *)dict;
+(NSArray *)itemsFromArray:(NSArray *)array;

@end
