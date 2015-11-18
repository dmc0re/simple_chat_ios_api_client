#import "HTTPResourcesManager.h"
#import "AFNetworking.h"

#import "Message.h"
#import "Channel.h"
#import "User.h"
#import "PaginationData.h"

static NSString *TARGET_URL = @"https://simplechad.herokuapp.com/api/v1";

static HTTPResourcesManager *instance = nil;

@interface HTTPResourcesManager()

@property(nonatomic, strong)AFHTTPRequestOperationManager *networkManager;

@end

@implementation HTTPResourcesManager

+(instancetype)manager
{
  if(!instance) {
    instance = [[self alloc] init];
    
    instance.networkManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:TARGET_URL]];
    instance.networkManager.operationQueue.suspended = NO;
  }
  return instance;
}

-(void)setCurrentUser:(User *)currentUser
{
  [_networkManager.requestSerializer setValue:currentUser.authToken forHTTPHeaderField:@"Authorization"];
  _currentUser = currentUser;
}

-(void)getChannelsIndexForPageNum:(NSInteger)page
                 beforeChannel:(Channel *)channel
                   withCompletion:(void (^)(NSArray *channels, PaginationData *pagination, NSInteger httpStatusCode))completion
{
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  params[@"page"] = @(page);
  if (channel) {
    params[@"before_id"] = @(channel.uid);
  }
  
  [_networkManager GET:[TARGET_URL stringByAppendingString:@"/channels"]
            parameters:params
               success:^(AFHTTPRequestOperation *operation, id responseObject)
   {
     NSArray *channels = [Channel itemsFromArray:responseObject[@"data"][@"channels"]];
     PaginationData *pagination = [[PaginationData alloc] initWithDictionary:responseObject];
     
     if (completion) {
       completion(channels, pagination, operation.response.statusCode);
     }
   }
               failure:^(AFHTTPRequestOperation *operation, NSError *error)
   {
     [self showAlerViewForError:error];
     if (completion) {
       completion(nil, nil, operation.response.statusCode);
     }
     NSLog(@"Failed to get channels list with error: %@", error);
   }];
}

-(void)createNewChannelWithName:(NSString *)name
                 withCompletion:(void (^)(Channel *channel, NSInteger httpStatusCode))completion
{
  [_networkManager POST:[TARGET_URL stringByAppendingString:@"/channels"]
             parameters:@{ @"name" : name }
                success:^(AFHTTPRequestOperation *operation, id responseObject)
   {
     Channel *c = [[Channel alloc] initWithDictionary:responseObject];
     if (completion) {
       completion(c, operation.response.statusCode);
     }
   }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
   {
     [self showAlerViewForError:error];
     if (completion) {
       completion(nil, operation.response.statusCode);
     }
     NSLog(@"Failed to create channel with error: %@", error);
   }];
}

-(void)getMessagesNewerThan:(Message *)message
                 forChannel:(Channel *)channel
             withCompletion:(void (^)(NSArray *messages, NSInteger httpStatusCode))completion
{
  NSString *URI = [TARGET_URL stringByAppendingString:[NSString stringWithFormat:@"/channels/%ld/messages", (long)channel.uid]];
  [_networkManager GET:URI
            parameters:@{ @"after_id" : message ? @(message.uid) : @(1) }
               success:^(AFHTTPRequestOperation *operation, id responseObject)
   {
     NSArray *messages = [Message itemsFromArray:responseObject[@"data"][@"messages"]];
     
     if (completion) {
       completion(messages, operation.response.statusCode);
     }
   }
               failure:^(AFHTTPRequestOperation *operation, NSError *error)
   {
     [self showAlerViewForError:error];
     if (completion) {
       completion(nil, operation.response.statusCode);
     }
     NSLog(@"Failed to get newer message with error: %@", error);
   }];

}

-(void)createMessageForChannel:(Channel *)channel
                          andText:(NSString *)text
                   withCompletion:(void (^)(Message *message, NSInteger httpStatusCode))completion
{
  NSString *URI = [TARGET_URL stringByAppendingString:[NSString stringWithFormat:@"/channels/%ld/messages", (long)channel.uid]];
  [_networkManager POST:URI
             parameters:@{ @"text" : text }
                success:^(AFHTTPRequestOperation *operation, id responseObject)
   {
     
     Message *m = [[Message alloc] initWithDictionary:responseObject];
     if (completion) {
       completion(m, operation.response.statusCode);
     }
   }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
   {
     [self showAlerViewForError:error];
     if (completion) {
       completion(nil, operation.response.statusCode);
     }
     NSLog(@"Failed to create message with error: %@", error);
   }];

}

-(void)getMessagesIndexForPageNum:(NSInteger)page
                    beforeMessage:(Message *)message
                       andChannel:(Channel *)channel
                   withCompletion:(void (^)(NSArray *messages, PaginationData *pagination, NSInteger httpStatusCode))completion
{
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  params[@"page"] = @(page);
  if (message) {
    params[@"before_id"] = @(message.uid);
  }
  
  NSString *URI = [TARGET_URL stringByAppendingString:[NSString stringWithFormat:@"/channels/%ld/messages", (long)channel.uid]];
  [_networkManager GET:URI
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject)
   {
     NSArray *messages = [Message itemsFromArray:responseObject[@"data"][@"messages"]];
     PaginationData *pagination = [[PaginationData alloc] initWithDictionary:responseObject];
     
     if (completion) {
       completion(messages, pagination, operation.response.statusCode);
     }
   }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
   {
     [self showAlerViewForError:error];
     if (completion) {
       completion(nil, nil, operation.response.statusCode);
     }
     NSLog(@"Failed to get messages list with error: %@", error);
   }];
}

-(void)createSessionForEmail:(NSString *)email
                 andPassword:(NSString *)password
            withCompletion:(void (^)(User *user, NSInteger httpStatusCode))completion
{
  [_networkManager POST:[TARGET_URL stringByAppendingString:@"/sessions"]
             parameters:@{ @"email" : email, @"password" : password }
                success:^(AFHTTPRequestOperation *operation, id responseObject)
   {
     
     User *user = [[User alloc] initWithDictionary:responseObject];
     if (completion) {
       completion(user, operation.response.statusCode);
     }
   }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
   {
     [self showAlerViewForError:error];
     if (completion) {
       completion(nil, operation.response.statusCode);
     }
     NSLog(@"Failed to сreate session with error: %@", error);
   }];

}

-(void)createUserWithEmail:(NSString *)email
                  andName:(NSString *)name
                 andPassword:(NSString *)password
              withCompletion:(void (^)(User *user, NSInteger httpStatusCode))completion
{
  [_networkManager POST:[TARGET_URL stringByAppendingString:@"/users"]
             parameters:@{ @"email" : email, @"name" : name, @"password" : password }
                success:^(AFHTTPRequestOperation *operation, id responseObject)
   {
     
     User *user = [[User alloc] initWithDictionary:responseObject];
     if (completion) {
       completion(user, operation.response.statusCode);
     }
   }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
   {
     [self showAlerViewForError:error];
     if (completion) {
       completion(nil, operation.response.statusCode);
     }
     NSLog(@"Failed to create user with error: %@", error);
   }];
  
}

-(void)showAlerViewForError:(NSError *)error
{
  if (error.code == -1004)
  {
    [[[UIAlertView alloc] initWithTitle:@"Ошибка!"
                                message:@"Сервер не доступен.\nПроверьте соединение с интернетом."
                               delegate:nil
                      cancelButtonTitle:@"Ок"
                      otherButtonTitles:nil] show];
  }
}

@end
