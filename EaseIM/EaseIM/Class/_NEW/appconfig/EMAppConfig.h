//
//  EMAppConfig.h
//  EaseIM
//
//  Created by 杨剑 on 2024/3/8.
//  Copyright © 2024 杨剑. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EMUserNotificationHelper.h"
#import "EaseIMHelper.h"
#import "EMAppCallHelper.h"
#import <Bugly/Bugly.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMAppConfig : NSObject

+ (instancetype)shared;

//初始化IM客户端
- (void)configIMClient;

//初始化音视频部分
- (void)configCallManager;

//注册推送
- (void)registerUserNotification;

//配置bugly
- (void)configBugly;

@end

NS_ASSUME_NONNULL_END
