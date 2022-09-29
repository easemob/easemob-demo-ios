//
//  EMHttpRequest.h
//
//  Created by zhangchong on 2021/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMHttpRequest : NSObject

+ (instancetype)sharedManager;

- (void)registerToApperServer:(NSString *)uName
                          pwd:(NSString *)pwd
                  phoneNumber:(NSString*)phoneNumber
                      smsCode:(NSString*)smsCode
                   completion:(void (^)(NSString*response))aCompletionBlock;

- (void)loginToAppServer:(NSString *)uName
                       pwd:(NSString *)pwd
                completion:(void (^)(NSInteger statusCode, NSString * _Nullable response))aCompletionBlock;

- (void)requestImageCodeWithCompletion:(void(^)(NSString*imageUrl,NSString*imageId))aCompletionBlock;
- (void)requestSMSWithPhone:(NSString*)phone imageId:(NSString*)imageId imageCode:(NSString*)imageCode  completion:(void(^)(NSString* _Nullable response))aCompletionBlock;
- (void)requestResetPwdCheckUserId:(NSString*)userId phoneNumber:(NSString*)phoneNumber smsCode:(NSString*)smsCode completion:(void(^)(NSString* _Nullable response))aCompletionBlock;
- (void)requestResetPwdUserId:(NSString*)userId newPassword:(NSString*)password completion:(void(^)(NSString* _Nullable response))aCompletionBlock;
@end

NS_ASSUME_NONNULL_END
