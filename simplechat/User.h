#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy)   NSString  *email;
@property (nonatomic, copy)   NSString  *authToken;


-(instancetype)initWithDictionary:(NSDictionary *)dict;

@end
