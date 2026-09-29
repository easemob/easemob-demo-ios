//
//  EMPushServiceExt.h
//  EMPushServiceExt
//
//  Created by hxq on 2022/2/16.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface EMPushServiceExt : NSObject
/*!
 *  \~chinese
 *   设置appkey（需要与main target中的appkey相同）
 *
 *   @param aAppkey   app唯一标识符
 *
 *  \~english
 *  Set appKey (needs to be the same as appKey in main Target)
 *
 *  @param aAppkey   Application's unique identifier
 *
 */
+ (void)setAppkey:(NSString *)aAppkey;

/*!
 *  \~chinese
 *   APNS推送送达上报
 *
 *  @param aRequest  apns请求
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *
 *  APNS push delivered and reported
 *  
 *  @param aRequest    apns request
 *  @param aCompletionBlock  The callback of completion block
 */
+ (void)receiveRemoteNotificationRequest:(UNNotificationRequest *)aRequest completion:(void (^)(NSError*error))aCompletionBlock;
@end

