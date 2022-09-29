//
//  EMResetPasswordViewController.m
//  EaseIM
//
//  Created by li xiaoming on 2022/8/8.
//  Copyright © 2022 li xiaoming. All rights reserved.
//

#import "EMResetPasswordViewController.h"

#import "EMRightViewToolView.h"
#import "EMHttpRequest.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSInteger resetMsgCodeTs = 0;

@interface EMResetPasswordViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) EMRightViewToolView *userIdRightView;

@property (nonatomic, strong) UITextField *phoneField;
@property (nonatomic, strong) EMRightViewToolView *phoneRightView;

@property (nonatomic, strong) UITextField *msgCodeField;
@property (nonatomic, strong) EMRightViewToolView *msgCodeRightView;

@property (nonatomic, strong) UITextField *imageCodeField;
@property (nonatomic, strong) EMRightViewToolView *imageCodeRightView;

@property (nonatomic, strong) UIButton* msgCodeButton;

@property (nonatomic, strong) UIImageView* imageCodeView;

@property (nonatomic,strong) NSString* imageId;

@property (nonatomic,strong) UIButton* resetButton;

@property (nonatomic) BOOL canResetPwd;

@property (nonatomic, strong) UITextField *pswdField;
@property (nonatomic, strong) EMRightViewToolView *pswdRightView;

@property (nonatomic, strong) UITextField *confirmPswdField;
@property (nonatomic, strong) EMRightViewToolView *confirmPswdRightView;
@end

@implementation EMResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.canResetPwd = NO;
    // Do any additional setup after loading the view.
    [self setupSubViews];
    self.navigationController.navigationBarHidden = YES;
}

- (void)setupSubViews
{
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"BootPage"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:imageView atIndex:0];
    
    UIView *backView = [[UIView alloc]init];
    backView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
    [self.view addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIButton *backButton = [[UIButton alloc]init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back_left"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backupAction) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backView).offset(44 + EMVIEWTOPMARGIN);
        make.left.equalTo(backView).offset(24);
        make.height.equalTo(@24);
        make.width.equalTo(@24);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"Reset Password", nil);
    titleLabel.textColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backView);
        make.top.equalTo(backButton.mas_bottom).offset(30);
        make.height.equalTo(@30);
        make.width.equalTo(backView);
    }];
    
    self.nameField = [[UITextField alloc] init];
    self.nameField.backgroundColor = [UIColor whiteColor];
    self.nameField.delegate = self;
    self.nameField.borderStyle = UITextBorderStyleNone;
    self.nameField.placeholder = NSLocalizedString(@"userId", nil);
    self.nameField.returnKeyType = UIReturnKeyDone;
    self.nameField.font = [UIFont systemFontOfSize:17];
    self.nameField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    self.nameField.layer.cornerRadius = 17;
    self.nameField.layer.borderWidth = 1;
    self.nameField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userIdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMUsernameRightView];
    [self.userIdRightView.rightViewBtn addTarget:self action:@selector(clearUserIdAction) forControlEvents:UIControlEventTouchUpInside];
    self.nameField.rightView = self.userIdRightView;
    self.userIdRightView.hidden = YES;
    [backView addSubview:self.nameField];
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(30);
        make.right.equalTo(backView).offset(-30);
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.height.equalTo(@35);
    }];
    
    self.phoneField = [[UITextField alloc] init];
    self.phoneField.backgroundColor = [UIColor whiteColor];
    self.phoneField.delegate = self;
    self.phoneField.borderStyle = UITextBorderStyleNone;
    self.phoneField.placeholder = NSLocalizedString(@"phoneNumber", nil);
    self.phoneField.returnKeyType = UIReturnKeyDone;
    self.phoneField.font = [UIFont systemFontOfSize:17];
    self.phoneField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.phoneField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.phoneField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    self.phoneField.leftViewMode = UITextFieldViewModeAlways;
    self.phoneField.layer.cornerRadius = 17;
    self.phoneField.layer.borderWidth = 1;
    self.phoneField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.phoneRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMUsernameRightView];
    [self.phoneRightView.rightViewBtn addTarget:self action:@selector(clearPhoneAction) forControlEvents:UIControlEventTouchUpInside];
    self.phoneField.rightView = self.phoneRightView;
    self.phoneRightView.hidden = YES;
    [backView addSubview:self.phoneField];
    [self.phoneField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(30);
        make.right.equalTo(backView).offset(-30);
        make.top.equalTo(self.nameField.mas_bottom).offset(20);
        make.height.equalTo(self.nameField);
    }];
    
    self.imageCodeField = [[UITextField alloc] init];
    self.imageCodeField.backgroundColor = [UIColor whiteColor];
    self.imageCodeField.delegate = self;
    self.imageCodeField.borderStyle = UITextBorderStyleNone;
    self.imageCodeField.placeholder = NSLocalizedString(@"register.imageCode", nil);
    self.imageCodeField.returnKeyType = UIReturnKeyDone;
    self.imageCodeField.font = [UIFont systemFontOfSize:17];
    self.imageCodeField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.imageCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.imageCodeField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    self.imageCodeField.leftViewMode = UITextFieldViewModeAlways;
    self.imageCodeField.layer.cornerRadius = 17;
    self.imageCodeField.layer.borderWidth = 1;
    self.imageCodeField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.imageCodeRightView = [[EMRightViewToolView alloc] initRightViewWithViewType:EMUsernameRightView];
    [self.imageCodeRightView.rightViewBtn addTarget:self action:@selector(clearImageCodeAction) forControlEvents:UIControlEventTouchUpInside];
    self.imageCodeField.rightView = self.imageCodeRightView;
    self.imageCodeRightView.hidden = YES;
    [backView addSubview:self.imageCodeField];
    [self.imageCodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(30);
        make.right.equalTo(backView).offset(-30-120);
        make.top.equalTo(self.phoneField.mas_bottom).offset(20);
        make.height.equalTo(self.nameField);
    }];
    
    self.imageCodeView = [[UIImageView alloc] init];
    [backView addSubview:self.imageCodeView];
    [self.imageCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageCodeField.mas_right).offset(10);
            make.right.equalTo(self.nameField);
            make.height.top.equalTo(self.imageCodeField);
    }];
    
    self.msgCodeField = [[UITextField alloc] init];
    self.msgCodeField.backgroundColor = [UIColor whiteColor];
    self.msgCodeField.delegate = self;
    self.msgCodeField.borderStyle = UITextBorderStyleNone;
    self.msgCodeField.placeholder = NSLocalizedString(@"register.messageCode", nil);
    self.msgCodeField.returnKeyType = UIReturnKeyDone;
    self.msgCodeField.font = [UIFont systemFontOfSize:17];
    self.msgCodeField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.msgCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.msgCodeField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    self.msgCodeField.leftViewMode = UITextFieldViewModeAlways;
    self.msgCodeField.layer.cornerRadius = 17;
    self.msgCodeField.layer.borderWidth = 1;
    self.msgCodeField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.msgCodeRightView = [[EMRightViewToolView alloc] initRightViewWithViewType:EMUsernameRightView];
    [self.msgCodeRightView.rightViewBtn addTarget:self action:@selector(clearMsgCodeAction) forControlEvents:UIControlEventTouchUpInside];
    self.msgCodeField.rightView = self.msgCodeRightView;
    self.msgCodeRightView.hidden = YES;
    [backView addSubview:self.msgCodeField];
    [self.msgCodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(30);
        make.right.equalTo(self.imageCodeField);
        make.top.equalTo(self.imageCodeField.mas_bottom).offset(20);
        make.height.equalTo(self.nameField);
    }];
    
    self.msgCodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.msgCodeButton setTitle:NSLocalizedString(@"register.getMessageCode", nil) forState:UIControlStateNormal];
    [self.msgCodeButton addTarget:self action:@selector(getMsgCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:self.msgCodeButton];
    [self.msgCodeButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.msgCodeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.msgCodeButton setTitleColor:[UIColor blueColor] forState:UIControlStateDisabled];
    [self.msgCodeButton setBackgroundColor:[UIColor grayColor]];
    self.msgCodeButton.layer.cornerRadius = 15;
    [self.msgCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.msgCodeField.mas_right).offset(5);
        make.right.equalTo(backView).offset(-30);
        make.top.equalTo(self.imageCodeView.mas_bottom).offset(20);
        make.height.equalTo(@30);
    }];
    
    
    self.resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.resetButton setTitle:NSLocalizedString(@"reset.next", nil) forState:UIControlStateNormal];
    [self.resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.resetButton setBackgroundColor:[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0]];
    self.resetButton.layer.cornerRadius = 15;
    [self.resetButton addTarget:self action:@selector(resetAction) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:self.resetButton];
    [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backView);
        make.top.equalTo(self.msgCodeField.mas_bottom).offset(30);
        make.height.equalTo(@30);
        make.left.equalTo(backView).offset(50);
    }];
    
    self.pswdField = [[UITextField alloc] init];
    self.pswdField.backgroundColor = [UIColor whiteColor];
    self.pswdField.delegate = self;
    self.pswdField.borderStyle = UITextBorderStyleNone;
    self.pswdField.placeholder = NSLocalizedString(@"password", nil);
    self.pswdField.font = [UIFont systemFontOfSize:17];
    self.pswdField.returnKeyType = UIReturnKeyDone;
    self.pswdField.secureTextEntry = YES;
    self.pswdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMPswdRightView];
    [self.pswdRightView.rightViewBtn addTarget:self action:@selector(pswdSecureAction:) forControlEvents:UIControlEventTouchUpInside];
    self.pswdField.rightView = self.pswdRightView;
    self.pswdRightView.hidden = YES;
    self.pswdField.rightViewMode = UITextFieldViewModeAlways;
    self.pswdField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    self.pswdField.leftViewMode = UITextFieldViewModeAlways;
    self.pswdField.layer.cornerRadius = 17;
    self.pswdField.layer.borderWidth = 1;
    self.pswdField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [backView addSubview:self.pswdField];
    self.pswdField.hidden = YES;
    [self.pswdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameField);
        make.right.equalTo(self.nameField);
        make.top.equalTo(self.nameField.mas_bottom).offset(20);
        make.height.equalTo(self.nameField);
    }];
    
    self.confirmPswdField = [[UITextField alloc] init];
    self.confirmPswdField.backgroundColor = [UIColor whiteColor];
    self.confirmPswdField.delegate = self;
    self.confirmPswdField.borderStyle = UITextBorderStyleNone;
    self.confirmPswdField.placeholder = NSLocalizedString(@"confirmPwd", nil);
    self.confirmPswdField.font = [UIFont systemFontOfSize:17];
    self.confirmPswdField.returnKeyType = UIReturnKeyDone;
    self.confirmPswdField.secureTextEntry = YES;
    self.confirmPswdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMPswdRightView];
    [self.confirmPswdRightView.rightViewBtn addTarget:self action:@selector(confirmPswdSecureAction:) forControlEvents:UIControlEventTouchUpInside];
    self.confirmPswdField.rightView = self.confirmPswdRightView;
    self.confirmPswdRightView.hidden = YES;
    self.confirmPswdField.rightViewMode = UITextFieldViewModeAlways;
    self.confirmPswdField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    self.confirmPswdField.leftViewMode = UITextFieldViewModeAlways;
    self.confirmPswdField.layer.cornerRadius = 17;
    self.confirmPswdField.layer.borderWidth = 1;
    self.confirmPswdField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [backView addSubview:self.confirmPswdField];
    self.confirmPswdField.hidden = YES;
    [self.confirmPswdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pswdField);
        make.right.equalTo(self.pswdField);
        make.top.equalTo(self.pswdField.mas_bottom).offset(20);
        make.height.equalTo(self.pswdField);
    }];
    
    NSInteger ts = [[NSDate date] timeIntervalSince1970];
    [self updateMsgCodeTitle:ts];
    [self updateImageCodeView];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchImageCodeView)];
    self.imageCodeView.userInteractionEnabled = YES;
    [self.imageCodeView addGestureRecognizer:tapGesture];
}

- (void)backupAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetAction
{
    NSString* userId = self.nameField.text;
    
    if ([userId length] == 0 ) {
        [EMAlertController showErrorAlert:NSLocalizedString(@"userOrPwdEmpty", nil)];
        return;
    }
    if(self.canResetPwd) {
        NSString* password = self.pswdField.text;
        NSString* confirmPwd = self.confirmPswdField.text;
        if ([password length] == 0 ) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"userOrPwdEmpty", nil)];
            return;
        }
        if(![password isEqualToString:confirmPwd]) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"pwdWrongInput", nil)];
            return;
        }
        [[EMHttpRequest sharedManager] requestResetPwdUserId:userId newPassword:password completion:^(NSString * _Nullable response) {
            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            if(body) {
                NSNumber* code = [body objectForKey:@"code"];
                if(code.intValue == 200) {
                    [EMAlertController showSuccessAlert:@"Reset password success"];
                    [self backupAction];
                }else{
                    [EMAlertController showAlertWithMessage:response];
                }
            }
        }];
    }else{
        NSString* phoneNumber = self.phoneField.text;
        NSString* smsCode = self.msgCodeField.text;
        if(phoneNumber.length <= 0) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"register.inputPhoneNumber", nil)];
            return;
        }
        if(smsCode.length <= 0) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"register.inputSMSCode", nil)];
            return;
        }
        [[EMHttpRequest sharedManager] requestResetPwdCheckUserId:self.nameField.text phoneNumber:phoneNumber smsCode:smsCode completion:^(NSString * _Nullable response) {
            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            if(body) {
                NSNumber* code = [body objectForKey:@"code"];
                if(code.intValue == 200) {
                    self.canResetPwd = YES;
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [EMAlertController showAlertWithMessage:response];
                    });
                }
            }
        }];
    }
}

- (void)setCanResetPwd:(BOOL)canResetPwd
{
    _canResetPwd = canResetPwd;
    
    if(canResetPwd) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.resetButton setTitle:NSLocalizedString(@"reset.complete", nil) forState:UIControlStateNormal];
            self.pswdField.hidden = NO;
            self.confirmPswdField.hidden = NO;
            self.msgCodeField.hidden = YES;
            self.nameField.hidden = YES;
            self.msgCodeButton.hidden = YES;
            self.imageCodeField.hidden = YES;
            self.imageCodeView.hidden = YES;
            self.phoneField.hidden = YES;
        });
        
    }
}

//清除用户名
- (void)clearUserIdAction
{
    self.nameField.text = @"";
    self.userIdRightView.hidden = YES;
}

- (void)clearPhoneAction
{
    self.phoneField.text = @"";
    self.phoneRightView.hidden = YES;
}

- (void)getMsgCodeAction {
    NSString* phoneNumber = self.phoneField.text;
    if(phoneNumber.length <= 0) {
        [EMAlertController showErrorAlert:NSLocalizedString(@"register.inputPhoneNumber", nil)];
        return;
    }
    NSString *pattern = @"1\\d{10}$";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSArray<NSTextCheckingResult *> *result = [regex matchesInString:phoneNumber options:0 range:NSMakeRange(0, phoneNumber.length)];
    if (!result || result.count == 0) {
        [EMAlertController showErrorAlert:@"Phone number is wrong"];
        return;
    }
    NSString* imageCode = self.imageCodeField.text;
    if(imageCode.length <= 0) {
        [EMAlertController showErrorAlert:NSLocalizedString(@"register.inputImageCode", nil)];
        return;
    }
    if(self.imageId.length <= 0) {
        [EMAlertController showErrorAlert:NSLocalizedString(@"register.updateImageCode", nil)];
        return;
    }
    [self updateImageCodeView];
    [[EMHttpRequest sharedManager] requestSMSWithPhone:phoneNumber imageId:self.imageId imageCode:imageCode completion:^(NSString * _Nonnull response) {
        NSDictionary* body = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        if(body) {
            NSNumber* code = [body objectForKey:@"code"];
            if(code.intValue == 200) {
                NSInteger ts = [[NSDate date] timeIntervalSince1970];
                resetMsgCodeTs = ts;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateMsgCodeTitle:ts];
                });
            }else{
                [EMAlertController showErrorAlert:response];
            }
        }
    }];
}

- (void)updateMsgCodeTitle:(NSInteger)ts
{
    __weak typeof(self) weakself = self;
    if(resetMsgCodeTs != 0 && ts - resetMsgCodeTs < 60) {
        [self.msgCodeButton setEnabled:NO];
        [weakself.msgCodeButton setTitle:[NSString stringWithFormat:@"%ld",resetMsgCodeTs+60-ts] forState:UIControlStateDisabled];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakself updateMsgCodeTitle:ts+1];
        });
    }else{
        [self.msgCodeButton setEnabled:YES];
        [self.msgCodeButton setTitle:NSLocalizedString(@"register.getMessageCode", nil) forState:UIControlStateNormal];
    }
}

- (void)clearMsgCodeAction {
    self.msgCodeField.text = @"";
    self.msgCodeRightView.hidden = YES;
}

- (void)clearImageCodeAction {
    self.imageCodeField.text = @"";
    self.imageCodeRightView.hidden = YES;
}

- (void)updateImageCodeView
{
    [[EMHttpRequest sharedManager] requestImageCodeWithCompletion:^(NSString * _Nonnull imageUrl, NSString * _Nonnull imageId) {
        self.imageId = imageId;
        if(imageId.length > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://a1.easemob.com/inside/app/image/%@",imageId]];
                [self.imageCodeView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"img_broken"] completed:nil];
            });
        }
    }];
}

- (void)touchImageCodeView
{
    [self updateImageCodeView];
}

@end
