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

@end

@implementation BQPersonalGroupEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _setupSubviews];
}


- (void)_setupSubviews
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"conversation", nil);
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
    
}

- (void)moreAction {
    EMConversationsViewController * conversationsVC= [[EMConversationsViewController alloc]init];

    [self.navigationController pushViewController:conversationsVC animated:YES];
}


@end
