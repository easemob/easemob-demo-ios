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
                   completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;

- (void)loginToApperServer:(NSString *)uName
                       pwd:(NSString *)pwd
                completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;

@end

NS_ASSUME_NONNULL_END
