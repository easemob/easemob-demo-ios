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

#import <UserNotifications/UserNotifications.h>
#import "AppDelegate.h"

#import "EaseIMHelper.h"
#import "SingleCallController.h"
#import "ConferenceController.h"
#import "EMGlobalVariables.h"
#import "EMDemoOptions.h"
#import "EMNotificationHelper.h"
#import "EMHomeViewController.h"
#import "EMLoginViewController.h"
#import "UserInfoStore.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Bugly/Bugly.h>
#import <EaseIMKit/EaseIMKit.h>
#import "EMUserDataModel.h"

#define FIRSTLAUNCH @"firstLaunch"

#import "EMAppConfig.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate,EaseCallDelegate,EMLocalNotificationDelegate, EaseUserUtilsDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _connectionState = EMConnectionConnected;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self _initDemo];
    [self _initHyphenate];
    
    [EMAppConfig.shared configBugly];
    
    [self.window makeKeyAndVisible];

    //移动到 easeimhelper 中
//    EaseUserUtils.shared.delegate = self;
    
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


#pragma mark - Hyphenate

- (void)_initHyphenate
{
//    EMDemoOptions *demoOptions = [EMDemoOptions sharedOptions];
//    [EaseIMKitManager initWithEMOptions:[demoOptions toOptions]];
//    gIsInitializedSDK = YES;
//    //初始化EaseIMHelper，注册 EMClient 监听
//    [EaseIMHelper shareHelper];
    [EMAppConfig.shared configIMClient];
    
    gIsInitializedSDK = YES;
    
    EMDemoOptions *demoOptions = [EMDemoOptions sharedOptions];
    if (demoOptions.isAutoLogin){
        [self loginStateDidChange_login];
    } else {
        [self loginStateDidChange_logout];
    }
}

- (void)loginStateDidChange_login{
    UINavigationController *navigationController = nil;
    
    {//登录成功加载主窗口控制器
        navigationController = (UINavigationController *)self.window.rootViewController;
        if (!navigationController || (navigationController && ![navigationController.viewControllers[0] isKindOfClass:[EMHomeViewController class]])) {
            EMHomeViewController *homeController = [[EMHomeViewController alloc] init];
            navigationController = [[UINavigationController alloc] initWithRootViewController:homeController];
        }
        
        [[EMClient sharedClient].pushManager getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions * _Nonnull aOptions, EMError * _Nonnull aError) {
            if (!aError) {
                [[EaseIMKitManager shared] cleanMemoryUndisturbMaps];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EMUserPushConfigsUpdateSuccess" object:nil];//更新用户重启App时，会话免打扰状态UI同步
            }
        }];
        [[EMClient sharedClient].groupManager getJoinedGroupsFromServerWithPage:0 pageSize:-1 completion:^(NSArray *aList, EMError *aError) {
            if (!aError) {
                [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_LIST_FETCHFINISHED object:nil];
            }
        }];
        
        
        [EMNotificationHelper shared];
        [[UserInfoStore sharedInstance] loadInfosFromLocal];
        [EMAppConfig.shared configCallManager];
        
//        NSString* path = [[NSBundle mainBundle] pathForResource:@"huahai128" ofType:@"mp3"];
//        config.ringFileUrl = [NSURL fileURLWithPath:path];
    }
//    navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_white"] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar.layer setMasksToBounds:YES];
    navigationController.view.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:18], NSFontAttributeName, nil]];
    [[UITableViewHeaderFooterView appearance] setTintColor:kColor_LightGray];
    
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//        statusBar.backgroundColor = [UIColor whiteColor];
//    }

}
- (void)loginStateDidChange_logout{
    UINavigationController *navigationController = nil;
    
    {//登录失败加载登录页面控制器
        EMLoginViewController *controller = [[EMLoginViewController alloc] init];
        navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    }
//    navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_white"] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar.layer setMasksToBounds:YES];
    navigationController.view.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:18], NSFontAttributeName, nil]];
    [[UITableViewHeaderFooterView appearance] setTintColor:kColor_LightGray];
    
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//        statusBar.backgroundColor = [UIColor whiteColor];
//    }

}

#pragma mark - Demo

- (void)_initDemo
{
    //注册登录状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChange:) name:ACCOUNT_LOGIN_CHANGED object:nil];
    //注册推送
//    [self _registerRemoteNotification];
    [EMAppConfig.shared registerUserNotification];
}


- (void)loginStateChange:(NSNotification *)aNotif
{
    BOOL loginSuccess = [aNotif.object boolValue];
    if (loginSuccess) {//登录成功加载主窗口控制器
        [self loginStateDidChange_login];
    } else {//登录失败加载登录页面控制器
        [self loginStateDidChange_logout];
    }
    return;
    
    UINavigationController *navigationController = nil;
    if (loginSuccess) {//登录成功加载主窗口控制器
        navigationController = (UINavigationController *)self.window.rootViewController;
        if (!navigationController || (navigationController && ![navigationController.viewControllers[0] isKindOfClass:[EMHomeViewController class]])) {
            EMHomeViewController *homeController = [[EMHomeViewController alloc] init];
            navigationController = [[UINavigationController alloc] initWithRootViewController:homeController];
        }
        
        [[EMClient sharedClient].pushManager getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions * _Nonnull aOptions, EMError * _Nonnull aError) {
            if (!aError) {
                [[EaseIMKitManager shared] cleanMemoryUndisturbMaps];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EMUserPushConfigsUpdateSuccess" object:nil];//更新用户重启App时，会话免打扰状态UI同步
            }
        }];
        [[EMClient sharedClient].groupManager getJoinedGroupsFromServerWithPage:0 pageSize:-1 completion:^(NSArray *aList, EMError *aError) {
            if (!aError) {
                [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_LIST_FETCHFINISHED object:nil];
            }
        }];
        
        
        [EMNotificationHelper shared];
        [SingleCallController sharedManager];
        [ConferenceController sharedManager];
        [[UserInfoStore sharedInstance] loadInfosFromLocal];
        EaseCallConfig* config = [[EaseCallConfig alloc] init];
        config.agoraAppId = @"15cb0d28b87b425ea613fc46f7c9f974";
        config.enableRTCTokenValidate = YES;

        [[EaseCallManager sharedManager] initWithConfig:config delegate:self];
//        NSString* path = [[NSBundle mainBundle] pathForResource:@"huahai128" ofType:@"mp3"];
//        config.ringFileUrl = [NSURL fileURLWithPath:path];
    } else {//登录失败加载登录页面控制器
        EMLoginViewController *controller = [[EMLoginViewController alloc] init];
        navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    }
    
//    navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_white"] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar.layer setMasksToBounds:YES];
    navigationController.view.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:18], NSFontAttributeName, nil]];
    [[UITableViewHeaderFooterView appearance] setTintColor:kColor_LightGray];
    
}
@end
