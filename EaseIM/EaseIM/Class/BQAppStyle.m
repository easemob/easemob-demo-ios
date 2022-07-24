//
//  ACDAppStyle.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "BQAppStyle.h"

@implementation BQAppStyle
+ (instancetype)shareAppStyle {
    static BQAppStyle *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = BQAppStyle.new;
    });
    
    return instance;
}


- (void)defaultStyle {

//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    self.isJiHuApp = [userDefault boolForKey:kIsJiHuApp];
         
    //UITabBarItem
    [UITabBarItem.appearance setTitleTextAttributes:@{
                                                      NSFontAttributeName : NFont(12.0f),
                                                      NSForegroundColorAttributeName : TextLabelBlackColor
                                                      } forState:UIControlStateNormal];
    [UITabBarItem.appearance setTitleTextAttributes:@{
                                                      NSFontAttributeName : NFont(12.0f),
                                                      NSForegroundColorAttributeName : COLOR_HEX(0x114EFF)
                                                      } forState:UIControlStateSelected];

    UITabBarItem.appearance.badgeColor = TextLabelPinkColor;

    //去黑线
//    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
//    [UITabBar appearance].layer.borderWidth = 0.0f;
//    [UITabBar appearance].clipsToBounds = YES;
//    [[UITabBar appearance] setTranslucent:YES];

}

- (void)matchNavigation {
    //make navigation not
    if(@available(iOS 15.0, *)) {
    UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor= [UIColor whiteColor];
    appearance.shadowColor= [UIColor clearColor];
    UINavigationBar.appearance.standardAppearance = appearance;
    UINavigationBar.appearance.scrollEdgeAppearance = appearance;
    }

}


- (void)updateNavAndTabbarWithIsJihuApp:(BOOL)isJihuApp {
    if (isJihuApp) {
        [UINavigationBar appearance].barStyle = UIBarStyleBlack;
        [UINavigationBar appearance].translucent = NO;
        [UINavigationBar appearance].tintColor = ViewBgBlackColor;
        [[UINavigationBar appearance] setBarTintColor:ViewBgBlackColor];
        
        [[UINavigationBar appearance] setTitleTextAttributes:
             [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#F5F5F5"], NSForegroundColorAttributeName, [UIFont systemFontOfSize:16.0], NSFontAttributeName, nil]];
    }else {
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:16.0], NSFontAttributeName, nil]];

        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar_white"] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance].layer setMasksToBounds:YES];
        [UINavigationBar appearance].backgroundColor = [UIColor whiteColor];
    }
}

//- (void)saveLoginType {
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    [userDefault setBool:self.isJiHuApp forKey:kIsJiHuApp];
//    [userDefault synchronize];
//}

@end

#undef kIsJiHuApp

