//
//  YGGroupApplyApprovalCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/20.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupApplyApprovalCell.h"
#import "BQAvatarTitleRoleCell.h"
#import "BQTitleAvatarCell.h"
#import "UserInfoStore.h"

@interface YGGroupApplyApprovalCell ()

@property (nonatomic, strong) UILabel *inviteLabel;
@property (nonatomic, strong) UILabel *applyLabel;
@property (nonatomic, strong) UILabel *groupNameLabel;
@property (nonatomic, strong) UIButton *agreeButton;
@property (nonatomic, strong) UIButton *declineButton;

@end


@implementation YGGroupApplyApprovalCell

- (void)prepare {
    [self.contentView addSubview:self.applyLabel];
    [self.contentView addSubview:self.groupNameLabel];
    [self.contentView addSubview:self.inviteLabel];
    [self.contentView addSubview:self.declineButton];
    [self.contentView addSubview:self.agreeButton];

}


- (void)placeSubViews {
    [self.applyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(kAvatarHeight);
    }];
    
    [self.groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(8.0);
        make.width.lessThanOrEqualTo(@(200.0));
        make.height.equalTo(@(10));
    }];

    [self.inviteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(8.0);
        make.width.lessThanOrEqualTo(@(200.0));
        make.height.equalTo(@(10));
    }];

    
    [self.declineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(8.0);
        make.width.equalTo(@(60.0));
        make.height.equalTo(@(28.0));
    }];

    
    [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(8.0);
        make.size.equalTo(self.declineButton);
        
    }];

}

- (void)updateWithObj:(id)obj {
    self.applyLabel.text = @"";
    self.groupNameLabel.text = @"";
    self.inviteLabel.text = @"";
    
}

- (void)declineButtonAction {
    if (self.approvalBlock) {
        self.approvalBlock(NO);
    }
}

- (void)agreeButtonAction {
    if (self.approvalBlock) {
        self.approvalBlock(YES);
    }
}


#pragma mark getter and setter
- (UILabel *)applyLabel {
    if (_applyLabel == nil) {
        _applyLabel = [[UILabel alloc] init];
        _applyLabel.font = NFont(14.0);
        _applyLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        _applyLabel.textAlignment = NSTextAlignmentLeft;
        _applyLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _applyLabel;
}

- (UILabel *)groupNameLabel {
    if (_groupNameLabel == nil) {
        _groupNameLabel = [[UILabel alloc] init];
        _groupNameLabel.font = NFont(12.0);
        _groupNameLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        _groupNameLabel.textAlignment = NSTextAlignmentLeft;
        _groupNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _groupNameLabel;

}

- (UILabel *)inviteLabel {
    if (_inviteLabel == nil) {
        _inviteLabel = [[UILabel alloc] init];
        _inviteLabel.font = NFont(12.0);
        _inviteLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        _inviteLabel.textAlignment = NSTextAlignmentLeft;
        _inviteLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _inviteLabel;
}

- (UIButton *)declineButton {
    if (_declineButton == nil) {
        _declineButton = [[UIButton alloc] init];
        [_declineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_declineButton setTitle:@"拒绝" forState:UIControlStateNormal];
        _declineButton.titleLabel.font = NFont(14.0);
        
        [_declineButton addTarget:self action:@selector(declineButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _declineButton.backgroundColor = [UIColor colorWithHexString:@"#EDEFF2"];
        _declineButton.layer.cornerRadius = 2.0;
    }
    return _declineButton;

}


- (UIButton *)agreeButton {
    if (_agreeButton == nil) {
        _agreeButton = [[UIButton alloc] init];
        [_agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_agreeButton setTitle:@"接受" forState:UIControlStateNormal];
        _agreeButton.titleLabel.font = NFont(14.0);
        
        [_agreeButton addTarget:self action:@selector(agreeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _agreeButton.backgroundColor = [UIColor colorWithHexString:@"#4697CA"];
        _agreeButton.layer.cornerRadius = 2.0;
    }
    return _agreeButton;

}


@end
