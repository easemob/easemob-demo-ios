//
//  BQAvatarTitleRoleCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/8.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQAvatarTitleRoleCell.h"
#import "BQTitleAvatarCell.h"
#import "UserInfoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BQAvatarTitleRoleCell ()
@property (nonatomic, strong) UIImageView* roleImageView;
@end


@implementation BQAvatarTitleRoleCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.roleImageView];
     
}


- (void)placeSubViews {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(kAvatarHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(8.0);
        make.width.lessThanOrEqualTo(@(200.0));
        make.height.equalTo(@(10));
    }];

    [self.roleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.nameLabel.mas_right).offset(5.0);
    }];

}

- (void)updateWithObj:(id)obj isOwner:(BOOL)isOwner {
    NSString *aUid = (NSString *)obj;
    
    EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:aUid];
    if(userInfo) {
        if(userInfo.avatarUrl.length > 0) {
            NSURL* url = [NSURL URLWithString:userInfo.avatarUrl];
            if(url) {
                [self.iconImageView sd_setImageWithURL:url completed:nil];
            }
        }else {
            [self.iconImageView setImage:ImageWithName(@"jh_user_icon")];
        }
             
        self.nameLabel.text = userInfo.nickname.length > 0 ? userInfo.nickname: userInfo.userId;
        self.roleImageView.hidden = !isOwner;
        
    }else{
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[aUid]];
    }
    
}


#pragma mark getter and setter
- (UIImageView *)roleImageView {
    if (_roleImageView == nil) {
        _roleImageView = [[UIImageView alloc] init];
        [_roleImageView setImage:ImageWithName(@"jh_group_owner")];
        _roleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _roleImageView;
}


@end
