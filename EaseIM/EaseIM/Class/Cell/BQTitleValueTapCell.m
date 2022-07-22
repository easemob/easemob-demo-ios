//
//  BQTitleValueTapCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/21.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQTitleValueTapCell.h"

@implementation BQTitleValueTapCell

- (void)prepare {
    
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.bottomLine];
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)placeSubViews {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kBQPadding * 1.6);
        make.width.equalTo(@(140.0));
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).offset(5.0);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-16.0);
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
        _detailLabel.font = Font(@"PingFang SC", 14.0);
        _detailLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _detailLabel;
}


@end
