//
//  EMHttpRequest.h
//
//  Created by zhangchong on 2021/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMHttpRequest : NSObject

+ (instancetype)sharedManager;

- (void)loginToAppServerWithPhone:(NSString *)phoneNumber
                          smsCode:(NSString *)smsCode
                       completion:(void (^)(NSString * _Nullable response))aCompletionBlock;

- (void)requestSMSWithPhone:(NSString*)phone completion:(void(^)(NSString* _Nullable response))aCompletionBlock;
@end

NS_ASSUME_NONNULL_END
