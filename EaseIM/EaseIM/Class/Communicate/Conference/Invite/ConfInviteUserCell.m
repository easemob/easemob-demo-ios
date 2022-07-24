//
//  ConfInviteUserCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "ConfInviteUserCell.h"
#import "UserInfoStore.h"


@interface ConfInviteUserCell()

@property (nonatomic, weak) IBOutlet UIImageView *checkView;

@end

@implementation ConfInviteUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.checkView.contentMode = UIViewContentModeScaleAspectFit;
    
if ([EMDemoOptions sharedOptions].isJiHuApp) {
    self.contentView.backgroundColor = ViewBgBlackColor;
    self.nameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
    self.checkView.image = ImageWithName(@"unSlected");
}else {
    self.contentView.backgroundColor = ViewBgWhiteColor;
    self.nameLabel.textColor = [UIColor colorWithHexString:@"#171717"];
    self.checkView.image = ImageWithName(@"yg_unSlected");

}

}


- (void)updateWithObj:(id)obj {
    NSString *username = (NSString *)obj;
    
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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsChecked:(BOOL)isChecked
{
    if (_isChecked != isChecked) {
        _isChecked = isChecked;
        if (isChecked) {
            self.checkView.image = [UIImage imageNamed:@"check"];
        } else {
if ([EMDemoOptions sharedOptions].isJiHuApp) {
            self.checkView.image = [UIImage imageNamed:@"unSlected"];
}else {
            self.checkView.image = ImageWithName(@"yg_unSlected");
}


        }
    }
}

@end
