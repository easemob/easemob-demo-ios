//
//  EMGroupMemberNickNameViewController.m
//  EaseIM
//
//  Created by 朱继超 on 2023/1/17.
//  Copyright © 2023 朱继超. All rights reserved.
//

#import "EMGroupMemberNickNameViewController.h"
#import "EaseGroupMemberAttributesCache.h"
#import "NSDictionary+Safely.h"

@interface EMGroupMemberNickNameViewController ()

@property (nonatomic) NSString *groupId;

@property (nonatomic) UITextField *nickNameField;

@property (nonatomic) UILabel *warningMessage;

@end

@implementation EMGroupMemberNickNameViewController

- (instancetype)initWithGroupId:(nonnull NSString *)groupId nickName:(nullable NSString *)name{
    if ([self init]) {
        self.groupId = groupId;
        self.nickName = name;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction)];
    [self.view addSubview:[self nickNameField]];
    [self.view addSubview:[self warningMessage]];
}

- (UITextField *)nickNameField {
    if (!_nickNameField) {
        _nickNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50)];
        _nickNameField.backgroundColor = [UIColor whiteColor];
        _nickNameField.placeholder = self.nickName ? self.nickName:NSLocalizedString(@"Please input your nick name in group",nil);
        _nickNameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 50)];
        _nickNameField.leftViewMode = UITextFieldViewModeAlways;
        _nickNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nickNameField.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    }
    return _nickNameField;
}

- (UILabel *)warningMessage {
    if (!_warningMessage) {
        _warningMessage = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.nickNameField.frame)+5, CGRectGetWidth(self.view.bounds)-40, 30)];
        _warningMessage.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        _warningMessage.text = NSLocalizedString(@"When you enter the group,you can see your nick name in the group.",nil);
        _warningMessage.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _warningMessage.numberOfLines = 0;
    }
    return _warningMessage;
}

- (void)saveAction {
    [self.view endEditing:YES];
    if ([self.nickNameField.text isEqualToString:@""] || self.nickNameField.text == nil) {
        self.nickNameField.text = @"";
    }
    [EMClient.sharedClient.groupManager setMemberAttribute:self.groupId userId:EMClient.sharedClient.currentUsername attributes:@{@"nickName":self.nickNameField.text} completion:^(EMError * _Nullable error) {
        if (error == nil) {
            [self showHint:NSLocalizedString(@"Modify successful!", nil)];
            [[EaseGroupMemberAttributesCache shareInstance] updateCacheWithGroupId:self.groupId userName:EMClient.sharedClient.currentUsername key:@"nickName" value:self.nickNameField.text];
            if (self.changeResult) {
                self.changeResult(self.nickNameField.text);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showHint:error.errorDescription];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
