//
//  YGGroupBanMemberCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/19.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupMuteMemberCell.h"
#import "UserInfoStore.h"

@interface YGGroupMuteMemberCell ()
@property (nonatomic, strong) UIImageView* accessoryImageView;
@property (nonatomic, strong) UIButton* unBanButton;
@property (nonatomic, strong) NSString* userId;

@end


@implementation YGGroupMuteMemberCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.unBanButton];
    
}


- (void)placeSubViews {

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(kAvatarHeight);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(8.0f);
        make.right.equalTo(self.unBanButton.mas_left);
    }];
    
    [self.unBanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.right.equalTo(self.contentView).offset(-16.0f);
        make.width.equalTo(@(58.0));
        make.height.equalTo(@(28.0));
    }];

}

- (void)updateWithObj:(id)obj {
    NSString *username = (NSString *)obj;
    
    self.userId = username;
    self.nameLabel.text = username;
    self.imageView.image = ImageWithName(@"jh_user_icon");
    EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:username];
    if(userInfo) {
        if(userInfo.nickName.length > 0) {
            self.nameLabel.text = userInfo.nickName;
        }
        if(userInfo.avatarUrl.length > 0) {
            NSURL* url = [NSURL URLWithString:userInfo.avatarUrl];
            if(url) {
                [self.imageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [self setNeedsLayout];
                }];
            }
        }
    }else{
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[username]];
    }
    
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
//        [_unBanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [_unBanButton setTitle:@"解禁" forState:UIControlStateNormal];
//
        [_unBanButton setImage:ImageWithName(@"yg_unMute") forState:UIControlStateNormal];
        [_unBanButton addTarget:self action:@selector(unBanButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _unBanButton.backgroundColor = [UIColor colorWithHexString:@"#4798CB"];
        _unBanButton.layer.cornerRadius = 4.0;
    }
    return _unBanButton;
}



@end
