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

- (void)loginToAppServerWithPhone:(NSString *)phoneNumber
                          smsCode:(NSString *)smsCode
                       completion:(void (^)(NSString * _Nullable response))aCompletionBlock
{
    if (phoneNumber.length <= 0 || smsCode.length <= 0) {
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/inside/app/user/login/V1",domain]];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    [headerDict setObject:@"application/json" forKey:@"Accept"];
    request.allHTTPHeaderFields = headerDict;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:phoneNumber forKey:@"phoneNumber"];
    [dict setObject:smsCode forKey:@"smsCode"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(responseData);
        }
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

- (void)requestSMSWithPhone:(NSString*)phone completion:(void(^)(NSString* _Nullable response))aCompletionBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/inside/app/sms/send/%@",domain,phone]];
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc] init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    [headerDict setObject:@"application/json" forKey:@"Accept"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
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
