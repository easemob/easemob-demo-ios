//
//  EMMsgPicMixTextBubbleView.h
//  EaseIM
//
//  Created by 娜塔莎 on 2019/11/22.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMMsgPicMixTextBubbleView : UIImageView

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *textImgBtn;

- (void)setModel:(EaseMessageModel *)model;

@end

NS_ASSUME_NONNULL_END
