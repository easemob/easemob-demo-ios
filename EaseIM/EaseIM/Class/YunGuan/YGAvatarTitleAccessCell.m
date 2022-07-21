//
//  YGAvatarTitleAccessCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/20.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGAvatarTitleAccessCell.h"
#import "YGSearchGroup.h"

@interface YGAvatarTitleAccessCell ()
@property (nonatomic, strong) UIImageView* accessoryImageView;
@property (nonatomic, strong) UILabel* detailLabel;
@property (nonatomic, strong)UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) NSString* groupId;

@end


@implementation YGAvatarTitleAccessCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    
}

- (void)placeSubViews {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(@(38.0));
    }];

    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(8.0);
    }];
    
}

- (void)updateWithObj:(id)obj {
    
    [self.detailLabel removeFromSuperview];
    [self.accessoryImageView removeFromSuperview];
    [self.contentView removeGestureRecognizer:self.tapGesture];
    
    YGSearchGroup *group = (YGSearchGroup *)obj;
    self.isGroupMember = group.isGroupMember;
    
    self.groupId = group.groupId;
    self.nameLabel.text = group.groupName;
    self.iconImageView.image = ImageWithName(@"jh_group_icon");


    if (self.isGroupMember) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(accessAction)];
        
        [self.contentView addGestureRecognizer:self.tapGesture];
        
        [self.contentView addSubview:self.accessoryImageView];
        [self.accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.width.equalTo(@(28.0));
            make.height.equalTo(@(28.0));
            make.right.equalTo(self.contentView).offset(-16.0);
        }];
    }else {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.detailLabel];
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-16.0);
        }];
        
    }
    
    
}

- (void)accessAction {
    if (self.accessBlock) {
        self.accessBlock(self.groupId);
    }
}

#pragma mark getter and setter
- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = NFont(12.0);
        _detailLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _detailLabel.text = @"请联系同事入群";
    }
    return _detailLabel;
}

- (UIImageView *)accessoryImageView {
    if (_accessoryImageView == nil) {
        _accessoryImageView = [[UIImageView alloc] init];
        [_accessoryImageView setImage:ImageWithName(@"jh_right_access")];
        _accessoryImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _accessoryImageView;
}


@end
