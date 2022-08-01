//
//  BQEnterSwitchViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/24.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQEnterSwitchViewController.h"
#import "UIColor+BQ.h"

@interface BQEnterSwitchViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *aSwitch;
@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation BQEnterSwitchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"选择登录app";
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.aSwitch];
    [self.view addSubview:self.loginButton];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(150.0);
        make.left.equalTo(self.view).offset(30.0);
        make.width.equalTo(@(100.0));
    }];
    
    [self.aSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.left.equalTo(self.titleLabel.mas_right).offset(20.0);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.aSwitch.mas_bottom).offset(50.0);
        make.left.equalTo(self.view).offset(30.0);
        make.right.equalTo(self.view).offset(-30.0);
        make.height.equalTo(@(44.0));
    }];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI];
}


- (void)updateUI {
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        [self.aSwitch setOn:YES];
        self.titleLabel.text = @"极狐App";
    }else {
        [self.aSwitch setOn:NO];
        self.titleLabel.text = @"运管App";
    }
}


#pragma mark action
- (void)switchAction {
    if (self.aSwitch.isOn) {
        [EaseIMKitOptions sharedOptions].isJiHuApp = YES;
        self.titleLabel.text = @"极狐App";
    }else {
        [EaseIMKitOptions sharedOptions].isJiHuApp = NO;
        self.titleLabel.text = @"运管App";
    }
    
}

- (void)loginButtonAction {
    
    [EaseIMKitManager.shared configuationIMKitIsJiHuApp:[EaseIMKitOptions sharedOptions].isJiHuApp];
    
    
    EaseLoginViewController *controller = [[EaseLoginViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}



- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _titleLabel;
}


- (UISwitch *)aSwitch {
    if (_aSwitch == nil) {
        _aSwitch = [[UISwitch alloc] init];
        [_aSwitch addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
        _aSwitch.onTintColor = [UIColor colorWithHexString:@"#04D0A4"];
    
    }
    return _aSwitch;
}


- (UIButton *)loginButton {
    if (_loginButton == nil) {
        _loginButton = [[UIButton alloc] init];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setTitle:@"登 录" forState:UIControlStateNormal];
        _loginButton.titleLabel.font = NFont(16.0);
        
        [_loginButton addTarget:self action:@selector(loginButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _loginButton.backgroundColor = [UIColor colorWithHexString:@"#4390C0"];
        _loginButton.layer.cornerRadius = 4.0;
        
    }
    return _loginButton;

}


@end
