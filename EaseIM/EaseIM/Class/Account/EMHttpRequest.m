//
//  EMHttpRequest.m
//
//  Created by zhangchong on 2021/8/23.
//

#import "EMHttpRequest.h"

static NSString* domain = @"a1.easemob.com";
@interface EMHttpRequest() <NSURLSessionDelegate>
@property (readonly, nonatomic, strong) NSURLSession *session;
@end
@implementation EMHttpRequest

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static EMHttpRequest *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EMHttpRequest alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 120;
        _session = [NSURLSession sessionWithConfiguration:configuration
                                                 delegate:self
                                            delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

- (void)registerToApperServer:(NSString *)uName
                          pwd:(NSString *)pwd
                  phoneNumber:(NSString*)phoneNumber
                      smsCode:(NSString*)smsCode
                   completion:(void (^)(NSString*err))aCompletionBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/inside/app/user/register",domain]];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    [headerDict setObject:@"application/json" forKey:@"Accept"];
    request.allHTTPHeaderFields = headerDict;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:uName forKey:@"userId"];
    [dict setObject:pwd forKey:@"userPassword"];
    [dict setObject:phoneNumber forKey:@"phoneNumber"];
    [dict setObject:smsCode forKey:@"smsCode"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if(data) {
            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",body);
            if(body) {
                NSNumber* code = [body objectForKey:@"code"];
                if(code.intValue == 200) {
                    if(aCompletionBlock) {
                        aCompletionBlock(nil);
                    }
                }else{
                    aCompletionBlock(responseData);
                }
                return;
            }
        }
        if(aCompletionBlock)
            aCompletionBlock(responseData);
    }];
    [task resume];
}

- (void)loginToAppServer:(NSString *)uName
                     pwd:(NSString *)pwd
              completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/inside/app/user/login",domain]];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    [headerDict setObject:@"application/json" forKey:@"Accept"];
    request.allHTTPHeaderFields = headerDict;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:uName forKey:@"userId"];
    [dict setObject:pwd forKey:@"userPassword"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}

- (void)requestImageCodeWithCompletion:(void(^)(NSString*imageUrl,NSString*imageId))aCompletionBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/inside/app/image",domain]];
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc] init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.allHTTPHeaderFields = headerDict;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data) {
            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",body);
            if(body) {
                NSNumber* code = [body objectForKey:@"code"];
                if(code.intValue == 200) {
                    NSDictionary* data = [body objectForKey:@"data"];
                    if(data) {
                        NSString* imageUrl = [data objectForKey:@"image_url"];
                        NSString* imageId = [data objectForKey:@"image_id"];
                        if(aCompletionBlock) {
                            aCompletionBlock(imageUrl,imageId);
                        }
                        return;
                    }
                }
            }
        }
        if(aCompletionBlock)
            aCompletionBlock(nil,nil);
    }];
    [task resume];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){//服务器信任证书
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];//服务器信任证书
            if(completionHandler)
                completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
}

- (void)requestSMSWithPhone:(NSString*)phone imageId:(NSString*)imageId imageCode:(NSString*)imageCode  completion:(void(^)(NSString* _Nullable response))aCompletionBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/inside/app/sms/send",domain]];
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc] init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    [headerDict setObject:@"application/json" forKey:@"Accept"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSDictionary* params = @{@"phoneNumber":phone,@"imageId":imageId,@"imageCode":imageCode};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    request.allHTTPHeaderFields = headerDict;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(responseData);
        }
    }];

    [task resume];
}

- (void)requestResetPwdCheckUserId:(NSString*)userId phoneNumber:(NSString*)phoneNumber smsCode:(NSString*)smsCode completion:(void(^)(NSString* _Nullable response))aCompletionBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/inside/app/user/reset/password",domain]];
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc] init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    [headerDict setObject:@"application/json" forKey:@"Accept"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSDictionary* params = @{@"phoneNumber":phoneNumber,@"smsCode":smsCode,@"userId":userId};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    request.allHTTPHeaderFields = headerDict;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(responseData);
        }
    }];

    [task resume];
}

- (void)requestResetPwdUserId:(NSString*)userId newPassword:(NSString*)password completion:(void(^)(NSString* _Nullable response))aCompletionBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/inside/app/user/%@/password",domain,userId]];
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc] init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    [headerDict setObject:@"application/json" forKey:@"Accept"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    NSDictionary* params = @{@"newPassword":password};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    request.allHTTPHeaderFields = headerDict;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(responseData);
        }
    }];

    [task resume];
}

@end
