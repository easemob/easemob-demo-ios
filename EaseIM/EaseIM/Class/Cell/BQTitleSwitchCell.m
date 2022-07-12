//
//  ELDTitleSwitchCell.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/9.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "BQTitleSwitchCell.h"

@implementation BQTitleSwitchCell

- (void)prepare {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.aSwitch];
}

- (void)placeSubViews {
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kBQPadding * 0.5);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.bottom.equalTo(self.contentView).offset(-kBQPadding * 0.5);
    }];
    
    [self.aSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nameLabel);
        make.left.equalTo(self.nameLabel.mas_right).offset(kBQPadding);
        make.right.equalTo(self.contentView).offset(-kBQPadding * 1.6);
    }];

}

- (void)switchAction {
    if (self.switchActionBlock) {
        self.switchActionBlock(self.aSwitch);
    }
}

#pragma mark getter and setter
- (UISwitch *)aSwitch {
    if (_aSwitch == nil) {
        _aSwitch = [[UISwitch alloc] init];
        [_aSwitch addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
        _aSwitch.onTintColor = [UIColor colorWithHexString:@"#04D0A4"];
    
    }
    return _aSwitch;
}

@end
