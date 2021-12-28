//
//  TranslateTextBubbleView.h
//  EaseIM
//
//  Created by lixiaoming on 2021/11/11.
//  Copyright © 2021 lixiaoming. All rights reserved.
//

#import "EMMsgBubbleView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TranslateTextBubbleView : EMMsgBubbleView
@property (nonatomic, readonly) EMMessageDirection direction;

@property (nonatomic, readonly) EMMessageType type;

@property (nonatomic, strong) EaseMessageModel *model;

@property (nonatomic, strong) EaseChatViewModel *viewModel;

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType;

- (void)setupBubbleBackgroundImage;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic) UIActivityIndicatorView * activity;
@end

NS_ASSUME_NONNULL_END
