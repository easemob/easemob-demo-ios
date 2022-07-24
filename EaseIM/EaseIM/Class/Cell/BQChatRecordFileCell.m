//
//  BQChatRecordFileCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/12.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQChatRecordFileCell.h"
#import "BQChatRecordFileModel.h"
#import "UserInfoStore.h"

@implementation BQChatRecordFileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupSubviews];
    }
    return self;
}


#pragma mark - Subviews
- (void)_setupSubviews
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _avatarView = [[UIImageView alloc] init];
    [self.contentView addSubview:_avatarView];
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(14);
        make.left.equalTo(self.contentView).offset(16);
        make.bottom.equalTo(self.contentView).offset(-14);
        make.width.equalTo(self.avatarView.mas_height).multipliedBy(1);
    }];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.font = [UIFont systemFontOfSize:16];
    _detailLabel.numberOfLines = 1;
    _detailLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    [self.contentView addSubview:_detailLabel];
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView).offset(-8);
    }];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.numberOfLines = 2;
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _nameLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.left.equalTo(self.avatarView.mas_right).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.detailLabel.mas_top);
    }];
    
    _timestampLabel = [[UILabel alloc] init];
    _timestampLabel.numberOfLines = 1;
    _timestampLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    _timestampLabel.font = [UIFont systemFontOfSize:12];
    [_timestampLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_timestampLabel];
    [_timestampLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarView);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    
if ([EMDemoOptions sharedOptions].isJiHuApp) {
    self.contentView.backgroundColor = ViewBgBlackColor;
    _nameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
    _timestampLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
    _detailLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
}else {

    self.contentView.backgroundColor = ViewBgWhiteColor;
    _nameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
    _timestampLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
    _detailLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
}
    
}

- (void)setModel:(BQChatRecordFileModel *)model
{
    _model = model;
    _avatarView.image = model.avatarImg;
    _nameLabel.text = model.from;
    _detailLabel.text = model.filename;
    _detailLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _timestampLabel.text = model.timestamp;
    
}

//- (void)updateWithObj:(id)obj {
//    EMChatMessage *msg = (EMChatMessage *)obj;
//    self.detailTextLabel.text =
//
//    self.avatarView.image = ImageWithName(@"jh_user_icon");
//    EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:msg.from];
//    if(userInfo) {
//        if(userInfo.nickName.length > 0) {
//            self.nameLabel.text = userInfo.nickName;
//        }
//        if(userInfo.avatarUrl.length > 0) {
//            NSURL* url = [NSURL URLWithString:userInfo.avatarUrl];
//            if(url) {
//                [self.avatarView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                    [self setNeedsLayout];
//                }];
//            }
//        }
//    }else{
//        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[msg.from]];
//    }
//}


@end

