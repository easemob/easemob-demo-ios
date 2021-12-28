//
//  EMGeneralCell.h
//  EaseIM
//
//  Created by liang on 2021/12/3.
//  Copyright © 2021 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMGeneralTitleSwitchCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UISwitch *aSwitch;
@property (nonatomic, copy) void (^switchActionBlock)(BOOL isOn);

@end

NS_ASSUME_NONNULL_END
