//
//  AntiFraudView.m
//  EaseIM
//
//  Created by li xiaoming on 2022/8/4.
//  Copyright © 2022 li xiaoming. All rights reserved.
//

#import "AntiFraudView.h"

@interface AntiFraudView ()
@property (nonatomic,strong) UIPanGestureRecognizer *panGesture;
@end

@implementation AntiFraudView
- (instancetype)init
{
    self = [super init];
    if(self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    //self.backgroundColor = [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1.0];
    self.textView = [[UITextView alloc] init];
    self.textView.layer.cornerRadius = 8;
    self.textView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.18];
    [self.textView setEditable:NO];
    [self.textView.textContainer setLineFragmentPadding:15];
    [self.textView setTextColor:[UIColor whiteColor]];
    [self addSubview:self.textView];
    self.textView.text = @"本应用仅用于环信产品功能开发测试，请勿用于非法用途。任何涉及转账、汇款、裸聊、网恋、网购退款、投资理财等统统都是诈骗，请勿相信。";
    self.textView.font = [UIFont systemFontOfSize:13];
}

- (void)layoutSubviews
{
    //self.textView.frame = CGRectMake(20, 150, self.frame.size.width - 40, 65);
}
@end
