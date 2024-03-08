//
//  EMAppConfig.m
//  EaseIM
//
//  Created by 杨剑 on 2024/3/8.
//  Copyright © 2024 杨剑. All rights reserved.
//

#import "EMAppConfig.h"




static EMAppConfig *appConfig = nil;

@implementation EMAppConfig

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appConfig = [[EMAppConfig alloc] init];
    });
    return appConfig;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc{
    
}

- (void)configIMClient{

    //初始化EaseIMHelper，注册 EMClient 监听
    
    EMDemoOptions *demoOptions = [EMDemoOptions sharedOptions];
//    demoOptions.isAutoAcceptGroupInvitation = true;
//    demoOptions.isAutoLogin = false;
//    demoOptions.enableConsoleLog = true;
//    demoOptions.usingHttpsOnly = true;
//    demoOptions.isPriorityGetMsgFromServer = true;
    [EaseIMKitManager initWithEMOptions:[demoOptions toOptions]];
    [EaseIMHelper shareHelper];
    
    
    if (demoOptions.isAutoLogin){
        [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@(YES)];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@(NO)];
    }

    
    NSLog(@"%@",EMClient.sharedClient.options);
    NSLog(@"%@",EMClient.sharedClient.options.appkey);

    NSLog(@"imkit version : %@",EaseIMKitManager.shared.version);
    NSLog(@"sdk   version : %@",EMClient.sharedClient.version);

}

- (void)configCallManager{
    [SingleCallController sharedManager];
    [ConferenceController sharedManager];
    EaseCallConfig* config = [[EaseCallConfig alloc] init];
    config.agoraAppId = @"15cb0d28b87b425ea613fc46f7c9f974";
    config.enableRTCTokenValidate = YES;
    [[EaseCallManager sharedManager] initWithConfig:config delegate:EMAppCallHelper.shared];
    
}

- (void)registerUserNotification{
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
    
    //先后顺序是有区别的.如果先设定苹果原生的UNUserNotificationCenter的delegate,后设置EMLocalNotificationManager的代理,则这个时候,EMLocalNotificationManager内部已经把你设定的UNUserNotificationCenter代理顶掉了.
    
    [[EMLocalNotificationManager sharedManager] launchWithDelegate:EMUserNotificationHelper.shared];
    UNUserNotificationCenter.currentNotificationCenter.delegate = EMUserNotificationHelper.shared;

    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *error) {
        if (granted) {
#if !TARGET_IPHONE_SIMULATOR
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication.sharedApplication registerForRemoteNotifications];
            });
#endif
        }
    }];
}

- (void)configBugly{
    BuglyConfig * config = [[BuglyConfig alloc] init];
    // 设置自定义日志上报的级别，默认不上报自定义日志
    config.reportLogLevel = BuglyLogLevelWarn;
    config.version = [EMClient sharedClient].version;
    config.deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    config.unexpectedTerminatingDetectionEnable = true;
    [Bugly startWithAppId:@"请填写您的 bugly ID" config:config];
}






@end
