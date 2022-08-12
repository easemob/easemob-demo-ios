/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "AppDelegate.h"


#import "EMHomeViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <UserNotifications/UserNotifications.h>
#import <Bugly/Bugly.h>

#import "BQEnterSwitchViewController.h"
#import "EMAlertView.h"


@interface AppDelegate () <UNUserNotificationCenterDelegate,EMLocalNotificationDelegate>

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    _connectionState = EMConnectionConnected;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self _initDemo];
    [self _initHyphenate];

    NSLog(@"imkit version : %@",EaseIMKitManager.shared.version);
    NSLog(@"sdk   version : %@",EMClient.sharedClient.version);
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    });
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"registefail", nil) message:error.description];
    [alertView show];
    
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    if (gMainController) {
//        [gMainController jumpToChatList];
//    }
    [[EMClient sharedClient] application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    if (gMainController) {
//        [gMainController didReceiveLocalNotification:notification];
//    }
}

//#pragma mark - UNUserNotificationCenterDelegate

/*
// 如果用户在app设置了UNUserNotificationCenter的代理delegate 则需要实现以下两个方法并调用em的相关方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    [[EMLocalNotificationManager sharedManager] userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler
{
    [[EMLocalNotificationManager sharedManager] userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
}
 */

#pragma mark - EMLocalPushManagerDelegate
/*
 //如果自己设置通知方式，则通过下面方式修改
- (void)emuserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"APNS userInfo : %@ : %@",userInfo);
    }else{
        NSLog(@"EaseMob userInfo : %@ \n ext : %@",userInfo,userInfo[@"ext"]);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);//通知方式 可选badge，sound，alert 如果实现了这个代理方法，则必须有completionHandler回调
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
*/

//如果需要获取数据 只实现这一个代理方法即可
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

//当应用收到环信推送透传消息时，此方法会被调用 注意这里是使用环信推送功能的透传消息
- (void)emDidRecivePushSilentMessage:(NSDictionary *)messageDic
{
    NSLog(@"emDidRecivePushSilentMessage : %@",messageDic);
    [self pushDataToTestLog:@"notificationlog:透传消息===" userInfo:messageDic];
}


-(void)pushDataToTestLog:(NSString*)keyStr userInfo:(NSDictionary*)userInfo
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[EMClient sharedClient] log:[NSString stringWithFormat:@"%@%@",keyStr,userInfo]];
}

#pragma mark - EMPushManagerDelegateDevice

// 打印收到的apns信息
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:NSLocalizedString(@"pushInfo", nil) message:str];
    [alertView show];
}

#pragma mark - Hyphenate

- (void)_initHyphenate
{
    EaseIMKitOptions *demoOptions = [EaseIMKitOptions sharedOptions];
//    demoOptions.appkey = @"您的appkey";
//    demoOptions.appkey = @"1100220606108201#demo";
    
//    demoOptions.appkey = @"1100220704109048#arcfox-server";
    [EaseIMKitManager managerWithEaseIMKitOptions:demoOptions];
}

#pragma mark - Demo

- (void)_initDemo
{
    //注册登录状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChange:) name:ACCOUNT_LOGIN_CHANGED object:nil];
    
    //注册推送
    [self _registerRemoteNotification];
    
}

//注册远程通知
- (void)_registerRemoteNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        [[EMLocalNotificationManager sharedManager] launchWithDelegate:self];
        
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
#if !TARGET_IPHONE_SIMULATOR
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
#endif
            }
        }];
        return;
    }
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}

- (void)loginStateChange:(NSNotification *)aNotif
{
    UINavigationController *navigationController = nil;
    
    BOOL loginSuccess = [aNotif.object boolValue];
    if (loginSuccess) {//登录成功加载主窗口控制器
        navigationController = (UINavigationController *)self.window.rootViewController;
        if (!navigationController || (navigationController && ![navigationController.viewControllers[0] isKindOfClass:[EMHomeViewController class]])) {
            EMHomeViewController *homeController = [[EMHomeViewController alloc] init];
            navigationController = [[UINavigationController alloc] initWithRootViewController:homeController];
        }
        
    } else {//登录失败加载登录页面控制器
        
        BQEnterSwitchViewController *controller = [[BQEnterSwitchViewController alloc] init];
        navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    }
    
    self.window.rootViewController = navigationController;
    navigationController.view.backgroundColor = ViewBgBlackColor;

}


@end
