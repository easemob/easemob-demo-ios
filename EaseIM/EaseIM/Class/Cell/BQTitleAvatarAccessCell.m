//
//  BQTitleAvatarAccessCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/19.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQTitleAvatarAccessCell.h"

@interface BQTitleAvatarAccessCell ()
@property (nonatomic, strong) UIImageView* accessoryImageView;
@end


@implementation BQTitleAvatarAccessCell

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

#pragma mark getter and setter
- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = NFont(14.0f);
        _detailLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _detailLabel;
}

- (UIImageView *)accessoryImageView {
    if (_accessoryImageView == nil) {
        _accessoryImageView = [[UIImageView alloc] init];
        [_accessoryImageView setImage:ImageWithName(@"gray_right_arrow")];
        _accessoryImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _accessoryImageView;
}


@end
