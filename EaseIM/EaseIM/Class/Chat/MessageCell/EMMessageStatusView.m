//
//  EMMessageStatusView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageStatusView.h"
#import "LoadingCALayer.h"
#import "OneLoadingAnimationView.h"
#import "EMMessageCell.h"

@interface EMMessageStatusView()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *failButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation EMMessageStatusView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - Subviews

- (UILabel *)label
{
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor grayColor];
        _label.font = [UIFont systemFontOfSize:13];
    }
    
    return _label;
}

- (UIButton *)failButton
{
    if (_failButton == nil) {
        _failButton = [[UIButton alloc] init];
        [_failButton setImage:[UIImage imageNamed:@"sendFail"] forState:UIControlStateNormal];
        [_failButton addTarget:self action:@selector(failButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _failButton;
}

- (void)failButtonAction
{
    if(self.resendCompletion) {
        self.resendCompletion();
    }
}


#pragma mark - Public

- (void)setSenderStatus:(EMMessageStatus)aStatus
            isReadAcked:(BOOL)aIsReadAcked
{
    if (aStatus == EMMessageStatusDelivering) {
        self.hidden = NO;
        [_label removeFromSuperview];
    } else if (aStatus == EMMessageStatusFailed) {
        self.hidden = NO;
        [self addSubview:self.failButton];
        [self.failButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@20);
            make.top.right.equalTo(self);
        }];
        [_label removeFromSuperview];
    } else if (aStatus == EMMessageStatusSucceed) {
        self.hidden = NO;
        self.label.text = aIsReadAcked ? NSLocalizedString(@"readed", nil) : nil;
        [self addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    } else {
        self.hidden = YES;
        [_label removeFromSuperview];
    }
}

@end
