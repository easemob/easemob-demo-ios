//
//  EMServiceCheckViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 2017/12/5.
//  Copyright © 2017年 EaseMob. All rights reserved.
//

#import "EMServiceCheckViewController.h"

#import "EMDemoOptions.h"

@interface EMServiceCheckViewController ()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) UILabel *dnsLabel;
@property (nonatomic, strong) UILabel *dnsValueLabel;

@property (nonatomic, strong) UILabel *tokenLabel;
@property (nonatomic, strong) UILabel *tokenValueLabel;

@property (nonatomic, strong) UILabel *loginLabel;
@property (nonatomic, strong) UILabel *loginValueLabel;

@end

@implementation EMServiceCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    self.username = options.loggedInUsername;
    self.password = options.loggedInPassword;
    
    [self _setupSubviews];
    [self serviceCheckBeginAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"begin", nil) style:UIBarButtonItemStylePlain target:self action:@selector(serviceCheckBeginAction)];
    
    self.title = NSLocalizedString(@"check", nil);
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    self.dnsLabel = [self _setupLabelWithStr:NSLocalizedString(@"dnsCheck", nil)];
    [self.view addSubview:self.dnsLabel];
    [self.dnsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.left.equalTo(self.view).offset(15);
        make.height.equalTo(@35);
    }];
    
    self.dnsValueLabel = [self _setupLabelWithStr:@"-"];
    [self.view addSubview:self.dnsValueLabel];
    [self.dnsValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dnsLabel);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@35);
    }];
    
    self.tokenLabel = [self _setupLabelWithStr:NSLocalizedString(@"tokenCheck", nil)];
    [self.view addSubview:self.tokenLabel];
    [self.tokenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dnsLabel.mas_bottom);
        make.left.equalTo(self.dnsLabel);
        make.height.equalTo(@35);
    }];
    
    self.tokenValueLabel = [self _setupLabelWithStr:@"-"];
    [self.view addSubview:self.tokenValueLabel];
    [self.tokenValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tokenLabel);
        make.right.equalTo(self.dnsValueLabel);
        make.height.equalTo(@35);
    }];
    
    self.loginLabel = [self _setupLabelWithStr:NSLocalizedString(@"loginCheck", nil)];
    [self.view addSubview:self.loginLabel];
    [self.loginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tokenLabel.mas_bottom);
        make.left.equalTo(self.dnsLabel);
        make.height.equalTo(@35);
    }];
    
    self.loginValueLabel = [self _setupLabelWithStr:@"-"];
    [self.view addSubview:self.loginValueLabel];
    [self.loginValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginLabel);
        make.right.equalTo(self.dnsValueLabel);
        make.height.equalTo(@35);
    }];
}

- (UILabel *)_setupLabelWithStr:(NSString *)aStr
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:17.f];
    label.text = aStr;
    return label;
}

#pragma mark - Action

- (void)_beginServiceCheck
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient] serviceCheckWithUsername:weakself.username password:weakself.password completion:^(EMServerCheckType aType, EMError *aError) {
        UILabel *label = nil;
        switch (aType) {
            case EMServerCheckAccountValidation:
                break;
            case EMServerCheckGetDNSListFromServer:
                label = weakself.dnsValueLabel;
                break;
            case EMServerCheckGetTokenFromServer:
                label = weakself.tokenValueLabel;
                break;
            case EMServerCheckDoLogin:
                label = weakself.loginValueLabel;
                break;
            case EMServerCheckDoLogout:
                break;
            default:
                break;
        }
        
        if (label) {
            if (aError) {
                label.text = @"-";
            } else {
                label.text = @"OK";
            }
        }
    }];
}

- (void)serviceCheckBeginAction
{
    self.dnsValueLabel.text = @"-";
    self.tokenValueLabel.text = @"-";
    self.loginValueLabel.text = @"-";
    
    if ([self.username length] == 0 || [self.password length] == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"fetchRight", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"pwd", nil);
            textField.secureTextEntry = YES;
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *passwordField = alertController.textFields.firstObject;
            self.password = passwordField.text;
            
            if ([EMClient sharedClient].isLoggedIn && ![self.username isEqualToString:[EMClient sharedClient].currentUsername]) {
                self.password = nil;
                [self showHint:NSLocalizedString(@"inputPwd", nil)];
                return ;
            }
            
            [self _beginServiceCheck];
        }];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self _beginServiceCheck];
    }
}

@end
