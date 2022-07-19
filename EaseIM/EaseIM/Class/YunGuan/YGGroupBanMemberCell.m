//
//  YGGroupBanMemberCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/19.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupBanMemberCell.h"

@interface YGGroupBanMemberCell ()
@property (nonatomic, strong) UIImageView* accessoryImageView;
@property (nonatomic, strong) UIButton* unBanButton;
@property (nonatomic, strong) NSString* userId;

@end


@implementation YGGroupBanMemberCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.bottomLine];
}

- (void)placeSubViews {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.right.equalTo(self.iconImageView.mas_left);
        
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.right.equalTo(self.contentView).offset(-16.0f);
        make.size.mas_equalTo(kAvatarHeight);
    }];
    
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@(BQ_ONE_PX));
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)updateWithObj:(id)obj {
    
}


- (void)unBanButtonAction {
    if (self.unBanBlock) {
        self.unBanBlock(self.userId);
    }
}

#pragma mark getter and setter
- (UIButton *)unBanButton {
    if (_unBanButton == nil) {
        _unBanButton = [[UIButton alloc] init];
        [_unBanButton addTarget:self action:@selector(unBanButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _unBanButton;
}

@end
