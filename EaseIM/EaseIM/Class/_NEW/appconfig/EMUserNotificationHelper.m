//
//  EMRemoteNotificationHelper.m
//  EaseIM
//
//  Created by yangjian on 2022/7/27.
//  Copyright © 2022 yangjian. All rights reserved.
//

#import "EMUserNotificationHelper.h"

static EMUserNotificationHelper *remoteNotificationHelper = nil;
@implementation EMUserNotificationHelper

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        remoteNotificationHelper = [[EMUserNotificationHelper alloc] init];
    });
    return remoteNotificationHelper;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

//#pragma mark - UNUserNotificationCenterDelegate

// 如果用户在app设置了UNUserNotificationCenter的代理delegate 则需要实现以下两个方法并调用em的相关方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    [EMLocalNotificationManager.sharedManager userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    [EMLocalNotificationManager.sharedManager userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
}

#pragma mark - EMLocalPushManagerDelegate
 //如果需要自己设置通知方式，则通过下面方式修改
- (void)emuserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
//    UNNotification *noti = nil;
    NSDictionary *userInfo = notification.request.content.userInfo;
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"APNS userInfo : %@",userInfo);
    }else{
        NSLog(@"EaseMob userInfo : %@ \n ext : %@",userInfo,userInfo[@"ext"]);
    }
    
    //通知方式 可选badge，sound，alert 如果实现了这个代理方法，则必须有completionHandler回调
//    completionHandler(UNNotificationPresentationOptionBadge
//                      |UNNotificationPresentationOptionSound
//                      |UNNotificationPresentationOptionAlert);
    completionHandler(0);
}

- (void)emuserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"APNS userInfo : %@ \n",userInfo);
    }else{
        NSLog(@"EaseMob userInfo : %@ \n ext : %@",userInfo,userInfo[@"ext"]);
    }
    completionHandler();//如果实现了这个代理方法 ，则必须有completionHandler回调
}

//如果需要获取数据 只实现这一个代理方法即可//
- (void)emGetNotificationMessage:(UNNotification *)notification state:(EMNotificationState)state
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //apns推送
        NSLog(@"userInfo : %@",userInfo);
        [self pushDataToTestLog:[NSString stringWithFormat:@"notificationlog:type==%@ channel==%@ title==%@ \n userInfo===",(state == EMWillPresentNotification?@"arrive":@"click"),@"apns推送",notification.request.content.title] userInfo:userInfo];
    }else{
        //本地推送
        NSLog(@"userInfo : %@ \n ext : %@",userInfo,userInfo[@"ext"]);
        [self pushDataToTestLog:[NSString stringWithFormat:@"notificationlog:type===%@ channel===%@ title===%@ \n userInfo===",(state == EMWillPresentNotification?@"arrive":@"click"),@"环信在线推送",notification.request.content.title] userInfo:userInfo];
    }

    if (state == EMDidReceiveNotificationResponse) {
        //通知被点开

    }else{
        //即将展示通知
    }

}

//当应用收到环信推送透传slient沉默消息时，此方法会被调用 注意!这里是使用环信推送功能的透传消息
////////emDidRecivePushSilentMessage
- (void)emDidRecivePushSilentMessage:(NSDictionary *)messageDic
{
    NSLog(@"emDidReceivePushSilentMessage : %@",messageDic);
    [self pushDataToTestLog:@"notificationlog:透传消息===" userInfo:messageDic];
}

//这里是写入log日志.是本文件内方法调用的,不是一个回调方法
-(void)pushDataToTestLog:(NSString*)keyStr userInfo:(NSDictionary*)userInfo
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[EMClient sharedClient] log:[NSString stringWithFormat:@"%@%@",keyStr,userInfo]];
}

// 打印收到的apns信息
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"pushInfo", nil) message:str];
    [alertView show];
}


////如果需要获取数据 只实现这一个代理方法即可
//- (void)emGetNotificationMessage:(UNNotification *)notification state:(EMNotificationState)state
//{
//    NSDictionary *userInfo = notification.request.content.userInfo;
//    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
//        //apns推送
//        NSLog(@"userInfo : %@",userInfo);
//        [self pushDataToTestLog:[NSString stringWithFormat:@"notificationlog:type==%@ channel==%@ title==%@ \n userInfo===",(state == EMWillPresentNotification?@"arrive":@"click"),@"apns推送",notification.request.content.title] userInfo:userInfo];
//    }else{
//        //本地推送
//        NSLog(@"userInfo : %@ \n ext : %@",userInfo,userInfo[@"ext"]);
//        [self pushDataToTestLog:[NSString stringWithFormat:@"notificationlog:type===%@ channel===%@ title===%@ \n userInfo===",(state == EMWillPresentNotification?@"arrive":@"click"),@"环信在线推送",notification.request.content.title] userInfo:userInfo];
//    }
//
//    if (state == EMDidReceiveNotificationResponse) {
//        //通知被点开
//
//    }else{
//        //即将展示通知
//    }
//
//}

////当应用收到环信推送透传消息时，此方法会被调用 注意这里是使用环信推送功能的透传消息
//- (void)emDidRecivePushSilentMessage:(NSDictionary *)messageDic
//{
//    NSLog(@"emDidRecivePushSilentMessage : %@",messageDic);
//    [self pushDataToTestLog:@"notificationlog:透传消息===" userInfo:messageDic];
//}
//
//-(void)pushDataToTestLog:(NSString*)keyStr userInfo:(NSDictionary*)userInfo
//{
//    NSError *parseError = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:&parseError];
//    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    [[EMClient sharedClient] log:[NSString stringWithFormat:@"%@%@",keyStr,userInfo]];
//}
//
//#pragma mark - EMPushManagerDelegateDevice
//
//// 打印收到的apns信息
//-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    NSError *parseError = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:&parseError];
//    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    
//    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"pushInfo", nil) message:str];
//    [alertView show];
//}



@end
