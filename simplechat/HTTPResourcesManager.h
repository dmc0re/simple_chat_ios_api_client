#import <Foundation/Foundation.h>

@class PaginationData;
@class Message;
@class Channel;
@class User;


@interface HTTPResourcesManager : NSObject

@property(nonatomic, strong)User *currentUser;

+(instancetype)manager;

-(void)getChannelsIndexForPageNum:(NSInteger)page
                 beforeChannel:(Channel *)channel
                   withCompletion:(void (^)(NSArray *channels, PaginationData *pagination, NSInteger httpStatusCode))completion;

-(void)createNewChannelWithName:(NSString *)name
                 withCompletion:(void (^)(Channel *channel, NSInteger httpStatusCode))completion;

-(void)getMessagesNewerThan:(Message *)message
                 forChannel:(Channel *) channel
                   withCompletion:(void (^)(NSArray *messages, NSInteger httpStatusCode))completion;

-(void)createMessageForChannel:(Channel *)channel
                          andText:(NSString *)text
                   withCompletion:(void (^)(Message *message, NSInteger httpStatusCode))completion;

-(void)getMessagesIndexForPageNum:(NSInteger)page
                    beforeMessage:(Message *)message
                       andChannel:(Channel *)channel
                   withCompletion:(void (^)(NSArray *messages, PaginationData *pagination, NSInteger httpStatusCode))completion;

-(void)createSessionForEmail:(NSString *)email
                 andPassword:(NSString *)password
              withCompletion:(void (^)(User *user, NSInteger httpStatusCode))completion;

-(void)createUserWithEmail:(NSString *)email
                  andName:(NSString *)name
              andPassword:(NSString *)password
            withCompletion:(void (^)(User *user, NSInteger httpStatusCode))completion;
@end
