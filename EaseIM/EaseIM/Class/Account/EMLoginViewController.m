//
//  EMLoginViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/11.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMLoginViewController.h"

#import "MBProgressHUD.h"

#import "EMDevicesViewController.h"
#import "EMQRCodeViewController.h"
#import "EMSDKOptionsViewController.h"

#import "EMGlobalVariables.h"
#import "EMDemoOptions.h"
#import "EMAlertController.h"
#import "EMErrorAlertViewController.h"
#import "EMRightViewToolView.h"
#import "EMAuthorizationView.h"
#import "EMHttpRequest.h"
#import "EMUserAgreementView.h"
#import "EMProtocolViewController.h"

@interface EMLoginViewController ()<UITextFieldDelegate,EMUserProtocol>

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UITextField *phoneField;
@property (nonatomic, strong) UITextField *smsField;
@property (nonatomic, strong) EMRightViewToolView *pswdRightView;
@property (nonatomic, strong) EMRightViewToolView *userIdRightView;
@property (nonatomic, strong) EMAuthorizationView *authorizationView;//授权操作视图

@property (nonatomic, strong) UIButton *serverConfigButton;
@property (nonatomic) BOOL isLogin;

@property (nonatomic, strong) UIImageView* sdkVersionBackView;
@property (nonatomic, strong) UILabel* titleLable;
@property (nonatomic, strong) UILabel* sdkVersionLable;
@property (nonatomic, strong) EMUserAgreementView *userAgreementView;//用户协议
@property (nonatomic, strong) UIButton* smsButton;
@property (nonatomic) NSInteger codeTs;

@end

@implementation EMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isLogin = false;
    [self _setupSubviews];
    self.codeTs = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.authorizationView originalView];//恢复原始视图
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = [UIImage imageNamed:@"BootPage"];
    [self.view insertSubview:imageView atIndex:0];
    
    self.backView = [[UIView alloc]init];
    self.backView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
    [self.view addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.titleLable = [[UILabel alloc] init];
    [self.backView addSubview:self.titleLable];
    self.titleLable.text = NSLocalizedString(@"login.title", nil);
    self.titleLable.font = [UIFont fontWithName:@"PingFang SC" size: 24];
    self.titleLable.textColor = [UIColor whiteColor];
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.bottom.equalTo(self.backView).multipliedBy(0.23);
        make.height.equalTo(@34);
    }];
    
    self.sdkVersionBackView = [[UIImageView alloc] init];
    self.sdkVersionBackView.image = [UIImage imageNamed:@"titleBackImage"];
    [self.backView addSubview:self.sdkVersionBackView];
    [self.sdkVersionBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLable.mas_right).offset(5);
        make.width.equalTo(@50);
        make.height.equalTo(@17);
        make.top.equalTo(self.titleLable.mas_top);
    }];
    
    self.sdkVersionLable = [[UILabel alloc] init];
    [self.backView addSubview:self.sdkVersionLable];
    self.sdkVersionLable.textColor = [UIColor whiteColor];
    self.sdkVersionLable.font = [UIFont fontWithName:@"PingFang SC" size:10];
    NSString* version = [NSString stringWithFormat:@"V%@",[[EMClient sharedClient] version] ];
    self.sdkVersionLable.text = version;
    self.sdkVersionLable.textAlignment = NSTextAlignmentCenter;
    
    [self.sdkVersionLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.sdkVersionBackView);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeDevelopMode)];
    tap.numberOfTapsRequired = 5;
    tap.numberOfTouchesRequired = 1;
    self.sdkVersionLable.userInteractionEnabled = YES;
    [self.sdkVersionLable addGestureRecognizer:tap];
    
    self.phoneField = [[UITextField alloc] init];
    self.phoneField.backgroundColor = [UIColor whiteColor];
    self.phoneField.delegate = self;
    self.phoneField.borderStyle = UITextBorderStyleNone;
    self.phoneField.placeholder = NSLocalizedString(@"phoneNumber", nil);
    self.phoneField.returnKeyType = UIReturnKeyGo;
    self.phoneField.font = [UIFont systemFontOfSize:17];
    self.phoneField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.phoneField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.phoneField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    self.phoneField.leftViewMode = UITextFieldViewModeAlways;
    self.phoneField.layer.cornerRadius = 24;
    self.phoneField.layer.borderWidth = 1;
    self.phoneField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userIdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMUsernameRightView];
    [self.userIdRightView.rightViewBtn addTarget:self action:@selector(clearUserIdAction) forControlEvents:UIControlEventTouchUpInside];
    self.phoneField.rightView = self.userIdRightView;
    self.userIdRightView.hidden = YES;
    [self.backView addSubview:self.phoneField];
    [self.phoneField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(30);
        make.right.equalTo(self.backView).offset(-30);
        make.top.equalTo(self.titleLable.mas_bottom).offset(22);
        make.height.equalTo(@48);
    }];
    self.smsField = [[UITextField alloc] init];
    self.smsField.backgroundColor = [UIColor whiteColor];
    self.smsField.delegate = self;
    self.smsField.borderStyle = UITextBorderStyleNone;
    self.smsField.placeholder = NSLocalizedString(@"register.messageCode", nil);
    self.smsField.font = [UIFont systemFontOfSize:17];
    self.smsField.returnKeyType = UIReturnKeyGo;
    self.smsField.secureTextEntry = YES;
    self.smsField.clearsOnBeginEditing = NO;
    self.pswdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMPswdRightView];
    [self.pswdRightView.rightViewBtn addTarget:self action:@selector(pswdSecureAction:) forControlEvents:UIControlEventTouchUpInside];
    self.smsField.rightView = self.pswdRightView;
    self.pswdRightView.hidden = YES;
    self.smsField.rightViewMode = UITextFieldViewModeAlways;
    self.smsField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    self.smsField.leftViewMode = UITextFieldViewModeAlways;
    self.smsField.layer.cornerRadius = 24;
    self.smsField.layer.borderWidth = 1;
    self.smsField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.backView addSubview:self.smsField];
    [self.smsField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(30);
        make.right.equalTo(self.backView).offset(-30);
        make.top.equalTo(self.phoneField.mas_bottom).offset(24);
        make.height.equalTo(self.phoneField);
    }];
    
    self.smsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.smsButton setTitle:NSLocalizedString(@"login.smsCode", "") forState:UIControlStateNormal];
    [self.smsButton.titleLabel setFont:[UIFont fontWithName:@"PingFang SC" size:14]];
    [self.backView addSubview:self.smsButton];
    [self.backView bringSubviewToFront:self.smsButton];
    [self.smsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.smsField);
        make.right.equalTo(self.smsField).offset(-25);
    }];
    [self.smsButton addTarget:self action:@selector(smsCodeAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self _setupLoginButton];
    [self updateMode];
}

- (void)smsCodeAction
{
    [self.backView endEditing:YES];
    NSString* phoneNumber = self.phoneField.text;
    if(phoneNumber.length <= 0) {
        [self showHint:NSLocalizedString(@"register.inputPhoneNumber", nil)];
        return;
    }
    NSString *pattern = @"1\\d{10}$";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSArray<NSTextCheckingResult *> *result = [regex matchesInString:phoneNumber options:0 range:NSMakeRange(0, phoneNumber.length)];
    if (!result || result.count == 0) {
        [self showHint: NSLocalizedString(@"login.wrongPhone", nil)];
        return;
    }

    [[EMHttpRequest sharedManager] requestSMSWithPhone:phoneNumber completion:^(NSString * _Nonnull response) {
        if (response.length <= 0) {
            [self showHint: NSLocalizedString(@"offlinePrompt", nil)];
            return;
        }
        NSDictionary* body = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        if(body) {
            NSNumber* code = [body objectForKey:@"code"];
            if(code.intValue == 200) {
                [self updateMsgCodeTitle:60];
                [self showHint:NSLocalizedString(@"login.codeSent", nil)];
            } else if (code.intValue == 400) {
                NSString * errorInfo = [body objectForKey:@"errorInfo"];
                if ([errorInfo isEqualToString:@"Please wait a moment while trying to send."]) {
                    [self showHint:NSLocalizedString(@"login.wait", nil)];
                } else
                if ([errorInfo containsString:@"exceed the limit of"]) {
                    [self showHint:NSLocalizedString(@"login.smsCodeLimit", nil)];
                } else {
                    [self showHint: errorInfo];
                }
            } else {
                [self showHint: response];
            }
        }
    }];
}

//授权登录按钮
- (void)_setupLoginButton
{
    self.authorizationView = [[EMAuthorizationView alloc]initWithAuthType:EMAuthLogin];
    self.authorizationView.userInteractionEnabled = YES;
    [self.authorizationView.authorizationBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.authorizationView];
    [self.authorizationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(30);
        make.right.equalTo(self.backView).offset(-30);
        make.top.equalTo(self.smsField.mas_bottom).offset(24);
        make.height.equalTo(self.smsField);
    }];
    
    UIButton *serverConfigurationBtn = [[UIButton alloc] init];
    serverConfigurationBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
    [serverConfigurationBtn setTitle:NSLocalizedString(@"serverConfig", nil) forState:UIControlStateNormal];
    [serverConfigurationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [serverConfigurationBtn addTarget:self action:@selector(changeAppkeyAction) forControlEvents:UIControlEventTouchUpInside];
    self.serverConfigButton = serverConfigurationBtn;

    [self.backView addSubview:serverConfigurationBtn];
    [serverConfigurationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.width.equalTo(@70);
        make.height.equalTo(@17);
        make.left.right.equalTo(self.authorizationView);
        make.bottom.equalTo(self.backView.mas_bottom).offset(-60);
    }];
    
    self.userAgreementView = [[EMUserAgreementView alloc]initUserAgreement];
    self.userAgreementView.delegate = self;
    [self.userAgreementView.userAgreementBtn addTarget:self action:@selector(confirmProtocol) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:_userAgreementView];
    [self.userAgreementView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.authorizationView.mas_bottom).offset(24);
        make.left.right.equalTo(self.authorizationView);
        make.height.equalTo(@(ComponentHeight));
    }];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.backView endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.phoneField.text.length > 0 && self.smsField.text.length > 0){
        [self.authorizationView setupAuthBtnBgcolor:YES];
        self.isLogin = true;
        [self loginAction];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor = kColor_Blue.CGColor;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    if (textField == self.phoneField && [self.phoneField.text length] == 0)
        self.userIdRightView.hidden = YES;
    if (textField == self.smsField && [self.smsField.text length] == 0)
        self.pswdRightView.hidden = YES;
    if(self.phoneField.text.length > 0 && self.smsField.text.length > 0){
        [self.authorizationView setupAuthBtnBgcolor:YES];
        self.isLogin = true;
        return;
    }
    [self.authorizationView setupAuthBtnBgcolor:NO];
    self.isLogin = false;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    if (textField == self.phoneField) {
        self.userIdRightView.hidden = NO;
        if ([self.phoneField.text length] <= 1 && [string isEqualToString:@""])
            self.userIdRightView.hidden = YES;
    }
    if (textField == self.smsField && EMDemoOptions.sharedOptions.isDevelopMode) {
        NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = updatedString;
        self.pswdRightView.hidden = NO;
        if ([self.smsField.text length] <= 0 && [string isEqualToString:@""]) {
            self.pswdRightView.hidden = YES;
            self.smsField.secureTextEntry = YES;
            [self.pswdRightView.rightViewBtn setSelected:NO];
        }
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidChangeSelection:(UITextField *)textField
{
    UITextRange *rang = textField.markedTextRange;
    if (rang == nil) {
        if(![self.phoneField.text isEqualToString:@""] && ![self.smsField.text isEqualToString:@""]){
            [self.authorizationView setupAuthBtnBgcolor:YES];
            self.isLogin = true;
            return;
        }
        [self.authorizationView setupAuthBtnBgcolor:NO];
        self.isLogin = false;
    }
}

#pragma mark - Action

//清除用户名
- (void)clearUserIdAction
{
    self.phoneField.text = @"";
    self.userIdRightView.hidden = YES;
}

- (void)qrCodeAction
{
    [self.backView endEditing:YES];
    
    if (gIsInitializedSDK) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"(づ｡◕‿‿◕｡)づ" message:NSLocalizedString(@"applyConfigPrompt", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"well", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }];
        [alertController addAction:okAction];
        
        [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        alertController.modalPresentationStyle = 0;
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        EMQRCodeViewController *controller = [[EMQRCodeViewController alloc] init];
        
        __weak typeof(self) weakself = self;
        [controller setScanFinishCompletion:^(NSDictionary *aJsonDic) {
            NSString *username = [aJsonDic objectForKey:@"Username"];
            NSString *pssword = [aJsonDic objectForKey:@"Password"];
            if ([username length] == 0) {
                return ;
            }
            
            [EMDemoOptions updateAndSaveServerOptions:aJsonDic];
            
            //weakself.appkeyField.text = [EMDemoOptions sharedOptions].appkey;
            weakself.phoneField.text = username;
            weakself.smsField.text = pssword;
            
            if ([pssword length] == 0) {
                [weakself.smsField becomeFirstResponder];
            }
        }];
        controller.modalPresentationStyle = 0;
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    }
}

- (void)changeAppkeyAction
{
    /*
    EMSDKOptionsViewController *controller = [[EMSDKOptionsViewController alloc] initWithEnableEdit:!gIsInitializedSDK finishCompletion:^(EMDemoOptions * _Nonnull aOptions) {
        //weakself.appkeyField.text = aOptions.appkey;
    }];*/
    EMSDKOptionsViewController *controller = [[EMSDKOptionsViewController alloc] initWithEnableEdit:YES finishCompletion:^(EMDemoOptions * _Nonnull aOptions) {
        //weakself.appkeyField.text = aOptions.appkey;
    }];
    
    controller.modalPresentationStyle = 0;
    [self.navigationController pushViewController:controller animated:YES];
    //[self presentViewController:controller animated:YES completion:nil];
}

- (void)pswdSecureAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    self.smsField.secureTextEntry = !self.smsField.secureTextEntry;
}

- (void)loginAction
{
    if(!self.isLogin) {
        return;
    }
    [self.backView endEditing:YES];
    if (self.smsField.text.length <= 0) {
        [self showHint:NSLocalizedString(@"login.enterSmsCode", nil)];
        return;
    }
    if (!self.userAgreementView.userAgreementBtn.isSelected) {
        [self showHint:NSLocalizedString(@"login.confirmTerms", nil)];
        return;
    }
    [self.backView endEditing:YES];
    
    NSString *name = self.phoneField.text;
    NSString *pswd = self.smsField.text;

    __weak typeof(self) weakself = self;
    void (^finishBlock) (NSString *aName, EMError *aError) = ^(NSString *aName, EMError *aError) {
        [weakself hideHud];
        
        if (!aError) {
            //设置是否自动登录
            [[EMClient sharedClient].options setIsAutoLogin:YES];
            
            EMDemoOptions *options = [EMDemoOptions sharedOptions];
            options.isAutoLogin = YES;
            options.loggedInUsername = aName;
            options.loggedInPassword = pswd;
            [options archive];
            [weakself.authorizationView originalView];
            //发送自动登录状态通知
            [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:[NSNumber numberWithBool:YES]];
            
            return ;
        }
        
        NSString *errorDes = NSLocalizedString(@"loginFailPrompt", nil);
        switch (aError.code) {
            case EMErrorUserNotFound:
                errorDes = NSLocalizedString(@"userNotFount", nil);
                break;
            case EMErrorNetworkUnavailable:
                errorDes = NSLocalizedString(@"offlinePrompt", nil);
                break;
            case EMErrorServerNotReachable:
                errorDes = NSLocalizedString(@"notReachServer", nil);
                break;
            case EMErrorUserAuthenticationFailed:
                errorDes = NSLocalizedString(@"userIdOrPwdError", nil);
                break;
            case EMErrorUserLoginTooManyDevices:
                errorDes = NSLocalizedString(@"devicesExceedLimit", nil);
                break;
            case EMErrorUserLoginOnAnotherDevice:
                errorDes = NSLocalizedString(@"loginOnOtherDevice", nil);
                break;
                case EMErrorUserRemoved:
                errorDes = NSLocalizedString(@"userRemovedByServer", nil);
            break;
            default:
                break;
        }
        [self showHint:errorDes];
        [self.authorizationView originalView];//恢复原始视图
    };
    
    [weakself.authorizationView beingLoadedView];//正在加载视图
    if([EMDemoOptions sharedOptions].isDevelopMode) {
        [[EMClient sharedClient] loginWithUsername:[name lowercaseString] password:pswd completion:finishBlock];
    }else{
        [[EMHttpRequest sharedManager] loginToAppServerWithPhone:[name lowercaseString] smsCode:pswd completion:^(NSString * _Nullable response) {
            if (response.length <= 0) {
                [self showHint: NSLocalizedString(@"offlinePrompt", nil)];
                [weakself.authorizationView originalView];
                return;
            }
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSNumber* code = [dic objectForKey:@"code"];
            if (!code) {
                [self showHint: NSLocalizedString(@"offlinePrompt", nil)];
                [weakself.authorizationView originalView];
                return;
            }
            if(code.intValue == 200) {
                NSString* token = [dic objectForKey:@"token"];
                [[EMClient sharedClient] loginWithUsername:[name lowercaseString] token:token completion:finishBlock];
            } else if(code.intValue == 400){
                NSString* errorInfo = [dic objectForKey:@"errorInfo"];
                if ([errorInfo isEqualToString:@"phone number illegal"]) {
                    [self showHint: NSLocalizedString(@"login.wrongPhone", nil)];
                    [weakself.authorizationView originalView];
                    return;
                }
                if ([errorInfo isEqualToString:@"SMS verification code error."]) {
                    [self showHint: NSLocalizedString(@"login.wrongSmsCode", nil)];
                    [weakself.authorizationView originalView];
                    return;
                }
                if ([errorInfo isEqualToString:@"Please send SMS to get mobile phone verification code."]) {
                    [self showHint: NSLocalizedString(@"login.wrongSmsCode", nil)];
                    [weakself.authorizationView originalView];
                    return;
                }
                [self showHint:errorInfo];
                [weakself.authorizationView originalView];
            } else {
                [self showHint:response];
                [weakself.authorizationView originalView];
            }
        }];
    }
    
 //   [[EMClient sharedClient] loginWithUsername:[name lowercaseString] password:pswd completion:finishBlock];
}

- (void)updateMode
{
    self.phoneField.keyboardType = EMDemoOptions.sharedOptions.isDevelopMode ? UIKeyboardTypeDefault : UIKeyboardTypeNumberPad;
    self.smsField.keyboardType = EMDemoOptions.sharedOptions.isDevelopMode ? UIKeyboardTypeDefault : UIKeyboardTypeNumberPad;
    self.smsField.secureTextEntry = EMDemoOptions.sharedOptions.isDevelopMode;
    self.phoneField.placeholder =  NSLocalizedString(EMDemoOptions.sharedOptions.isDevelopMode? @"userId" : @"phoneNumber", nil);
    self.smsField.placeholder = NSLocalizedString(EMDemoOptions.sharedOptions.isDevelopMode?  @"password" : @"register.messageCode", nil);
    self.serverConfigButton.hidden = !EMDemoOptions.sharedOptions.isDevelopMode;
    self.smsButton.hidden = EMDemoOptions.sharedOptions.isDevelopMode;
}

- (void)changeDevelopMode
{
    NSString* title = NSLocalizedString(EMDemoOptions.sharedOptions.isDevelopMode ? @"login.closeDebugMode" : @"login.openDebugMode", nil);
    UIAlertController* ac = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(EMDemoOptions.sharedOptions.isDevelopMode) {
            EMDemoOptions.sharedOptions.appkey = DEF_APPKEY;
        }
        EMDemoOptions.sharedOptions.isDevelopMode = !EMDemoOptions.sharedOptions.isDevelopMode;
        [self updateMode];
        [EMDemoOptions.sharedOptions archive];
    }];
    [ac addAction:okAction];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [ac addAction:cancelAction];
    [self presentViewController:ac animated:YES completion:nil];
}


#pragma mark - EMUserProtocol

- (void)didTapUserProtocol:(NSString *)protocolUrl sign:(NSString *)sign
{
    EMProtocolViewController *protocolController = [[EMProtocolViewController alloc]initWithUrl:protocolUrl sign:sign];
    protocolController.modalPresentationStyle = 0;
    [self presentViewController:protocolController animated:YES completion:nil];
}

#pragma mark - Action

- (void)confirmProtocol
{
    if(![self.phoneField.text isEqualToString:@""] && ![self.smsField.text isEqualToString:@""] && self.userAgreementView.userAgreementBtn.isSelected){
        self.isLogin = YES;
        return;
    }
    self.isLogin = NO;
}

- (void)updateMsgCodeTitle:(NSInteger)ts
{
    __weak typeof(self) weakself = self;
    self.codeTs = ts;
    if(self.codeTs > 0) {
        [self.smsButton setEnabled:NO];
        NSString* title = [NSString stringWithFormat:@"%@(%ld)",NSLocalizedString(@"login.getAfter", nil),ts];
        self.smsButton.titleLabel.text = title;
        [self.smsButton setTitle:title forState:UIControlStateDisabled];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakself updateMsgCodeTitle:weakself.codeTs-1];
        });
    }else{
        [self.smsButton setEnabled:YES];
        [self.smsButton setTitle:NSLocalizedString(@"login.smsCode", nil) forState:UIControlStateNormal];
    }
}

- (void)showHint:(NSString *)hint
{
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:win animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hint;
    hud.label.numberOfLines = 0;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.layer.cornerRadius = 10;
    hud.bezelView.backgroundColor = [UIColor blackColor];
    hud.contentColor = [UIColor whiteColor];
    hud.margin = 15.f;
    CGPoint offset = hud.offset;
    offset.y = 200;
    hud.offset = offset;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}

@end
