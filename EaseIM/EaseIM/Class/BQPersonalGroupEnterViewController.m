//
//  BQPersonalGroupEnterViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/14.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQPersonalGroupEnterViewController.h"
#import "EMConversationsViewController.h"

@interface BQPersonalGroupEnterViewController ()

@property (nonatomic, strong) UITextField *searchTextField;


@end

@implementation BQPersonalGroupEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes)];
    [self.view addGestureRecognizer:tap];
    
    [self _setupSubviews];
}

- (void)tapGes {
    [self.view endEditing:NO];
    
}

- (void)_setupSubviews
{
    
    self.view.backgroundColor = UIColor.whiteColor;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"极狐app Demo";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(EMVIEWTOPMARGIN + 35);
        make.height.equalTo(@25);
    }];
    
    UIButton *addImageBtn = [[UIButton alloc]init];
    [addImageBtn setImage:[UIImage imageNamed:@"icon-add"] forState:UIControlStateNormal];
    [addImageBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addImageBtn];
    [addImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@35);
        make.centerY.equalTo(titleLabel);
        make.right.equalTo(self.view).offset(-16);
    }];
    
if ([EMDemoOptions sharedOptions].isJiHuApp) {
    titleLabel.text = @"极狐app Demo";
    [self searchGroupAndUser];

}else {
    titleLabel.text = @"运管端app Demo";

}

   
}

- (void)searchGroupAndUser {
    
    self.searchTextField = [[UITextField alloc] init];
    self.searchTextField.backgroundColor = [UIColor lightGrayColor];
    self.searchTextField.delegate = self;
    self.searchTextField.borderStyle = UITextBorderStyleNone;
    self.searchTextField.placeholder = @"搜索id";
    self.searchTextField.returnKeyType = UIReturnKeyGo;
    self.searchTextField.font = [UIFont systemFontOfSize:17];
    self.searchTextField.textColor = UIColor.whiteColor;
    self.searchTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    
    
    UIButton *groupChatButton = [[UIButton alloc] init];
    groupChatButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [groupChatButton setTitle:@"创建群聊" forState:UIControlStateNormal];
    [groupChatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [groupChatButton addTarget:self action:@selector(groupChatButtonAction) forControlEvents:UIControlEventTouchUpInside];
    groupChatButton.backgroundColor = UIColor.blueColor;
    
    UIButton *singleChatButton = [[UIButton alloc] init];
    singleChatButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [singleChatButton setTitle:@"创建单聊" forState:UIControlStateNormal];
    [singleChatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [singleChatButton addTarget:self action:@selector(singleChatButtonAction) forControlEvents:UIControlEventTouchUpInside];
    singleChatButton.backgroundColor = UIColor.blueColor;

    [self.view addSubview:self.searchTextField];
    [self.view addSubview:groupChatButton];
    [self.view addSubview:singleChatButton];
    
    [self.searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100.0);
        make.left.equalTo(self.view).offset(30.0);
        make.right.equalTo(self.view).offset(-30.0);
        make.height.equalTo(@(44.0));
    }];
    
    [groupChatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchTextField.mas_bottom).offset(10.0);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(100.0));
        make.height.equalTo(@(44.0));
    }];

    
    [singleChatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(groupChatButton.mas_bottom).offset(10.0);
        make.centerX.equalTo(self.view);
        make.size.equalTo(groupChatButton);
    }];
}



- (void)groupChatButtonAction {
    EMConversation *groupChat =  [[EMClient sharedClient].chatManager getConversation:self.searchTextField.text type:EMConversationTypeGroupChat createIfNotExist:YES];
}


- (void)singleChatButtonAction {
 
    EMConversation *singleChat =  [[EMClient sharedClient].chatManager getConversation:self.searchTextField.text type:EMConversationTypeChat createIfNotExist:YES];
}


- (void)moreAction {
    EMConversationsViewController * conversationsVC= [[EMConversationsViewController alloc]init];

    [self.navigationController pushViewController:conversationsVC animated:YES];
}


@end
