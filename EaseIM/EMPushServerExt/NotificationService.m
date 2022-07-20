//
//  NotificationService.m
//  EMPushServerExt
//
//  Created by hxq on 2022/4/7.
//  Copyright © 2022 hxq. All rights reserved.
//

#import "NotificationService.h"
#import <EMPushExtension/EMPushServiceExt.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    [EMPushServiceExt setAppkey:@"easemob-demo#testy"];//填自己应用对应的appkey,必须和主应用中的appkey一致
    [EMPushServiceExt receiveRemoteNotificationRequest:request completion:^(NSError * _Nonnull error) {
        if (!error) {
            NSLog(@"EMPushServiceExt complete apns delivery");
        }
        self.contentHandler(self.bestAttemptContent);
    }];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
