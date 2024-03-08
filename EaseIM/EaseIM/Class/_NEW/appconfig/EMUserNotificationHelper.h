//
//  EMRemoteNotificationHelper.h
//  EaseIM
//
//  Created by yangjian on 2022/7/27.
//  Copyright © 2022 yangjian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMUserNotificationHelper : NSObject
<
UNUserNotificationCenterDelegate
,EMLocalNotificationDelegate
>

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
