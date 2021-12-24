//
//  EMGeneralCell.m
//  EaseIM
//
//  Created by liang on 2021/12/3.
//  Copyright © 2021 liang. All rights reserved.
//

#import "EMGeneralTitleSwitchCell.h"

@implementation EMGeneralTitleSwitchCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
        [self prepare];
        [self placeSubViews];
    }
    return self;
}


- (void)prepare {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.aSwitch];
}

- (void)placeSubViews {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0);
        make.right.equalTo(self.aSwitch.mas_left).offset(-10.0);
    }];
    
    [self.aSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nameLabel);
        make.right.equalTo(self.contentView).offset(-16.0);
    }];

}

- (void)switchAction {
    BOOL isOn = self.aSwitch.isOn;
    if (self.switchActionBlock) {
        self.switchActionBlock(isOn);
    }
}

#pragma mark getter and setter
- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        _nameLabel.font = [UIFont systemFontOfSize:14.0];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
    }
    return _nameLabel;
}


- (UISwitch *)aSwitch {
    if (_aSwitch == nil) {
        _aSwitch = [[UISwitch alloc] init];
        [_aSwitch addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
    }
    return _aSwitch;
}

@end
