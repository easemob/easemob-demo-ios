//
//  EMSettingViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/27.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQTSettingViewController.h"
#import "EMAlertView.h"

@interface BQTSettingViewController ()
@property (nonatomic, strong) UIButton *logoutButton;

@end

@implementation BQTSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.logoutButton];
    [self.logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.equalTo(self.view).offset(30.0);
        make.right.equalTo(self.view).offset(-30.0);
        make.height.equalTo(@(44.0));
    }];
}


- (UIButton *)logoutButton {
    if (_logoutButton == nil) {
        _logoutButton = [[UIButton alloc] init];
        _logoutButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_logoutButton setTitle:@"退出登录" forState:UIControlStateNormal];
        [_logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_logoutButton addTarget:self action:@selector(logoutButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _logoutButton.backgroundColor = UIColor.blueColor;
    }
    return _logoutButton;
}


- (void)logoutButtonAction {
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        [[EMClient sharedClient] logout:YES completion:^(EMError * _Nullable aError) {
            if (aError == nil) {
                EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:nil message:@"退出登录成功"];
                [alertView show];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@NO];

            }else {
                EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:nil message:aError.errorDescription];
                [alertView show];
                
                NSLog(@"err:%@",aError.errorDescription);
            }
            
        }];
        
    }else {
        [EaseIMKitManager.shared logoutWithCompletion:^(BOOL success, NSString * _Nonnull errorMsg) {
            if (success) {
                EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:nil message:@"退出登录成功"];
                [alertView show];
            }else {
                EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:nil message:errorMsg];
                [alertView show];
                
                NSLog(@"err:%@",errorMsg);
            }
            
        }];
    }
}

@end
