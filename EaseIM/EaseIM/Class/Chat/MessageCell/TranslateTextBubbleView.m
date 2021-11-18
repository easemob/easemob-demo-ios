//
//  TranslateTextBubbleView.m
//  EaseIM
//
//  Created by lixiaoming on 2021/11/11.
//  Copyright © 2021 lixiaoming. All rights reserved.
//

#import "TranslateTextBubbleView.h"

@implementation TranslateTextBubbleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
{
    self = [super init];
    if (self) {
        _direction = aDirection;
        _type = aType;
        [self setupSubViews];
    }
    
    return self;
}

- (void)setupBubbleBackgroundImage
{
    if (self.direction == EMMessageDirectionSend) {
        self.backgroundColor = [UIColor colorWithRed:225/255.0 green:235/255.0 blue:252/255.0 alpha:1.0];
        //self.image = [[UIImage imageNamedFromBundle:@"msg_bg_send"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    } else {
        self.layer.borderWidth = 1;
        self.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
        self.layer.borderColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:241/255.0 alpha:1.0].CGColor;
    }
}

- (void)setupSubViews
{
    [self setupBubbleBackgroundImage];
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:12];
    self.textLabel.numberOfLines = 0;
    [self addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.bottom.equalTo(self).offset(-10);
        make.left.equalTo(self.mas_left).offset(30);
        make.right.equalTo(self.mas_right).offset(-10);
    }];
    self.textLabel.textColor = [UIColor blackColor];
}
#pragma mark - Setter

- (void)setModel:(EaseMessageModel *)model
{
    EMTextMessageBody *body = (EMTextMessageBody *)model.message.body;
    self.textLabel.text = body.text;
}

- (UIActivityIndicatorView*)activity
{
    if(!_activity) {
        _activity = [[UIActivityIndicatorView alloc] init];
        _activity.backgroundColor = [UIColor whiteColor];
        if(@available(iOS 13.0, *)) {
            _activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
        }else{
            _activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        }
        [self addSubview:_activity];
        [_activity mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.top.equalTo(self).offset(10);
            make.width.height.equalTo(@15);
            if(self.textLabel.text.length <= 0) {
                make.bottom.equalTo(self).offset(-10);
            }
        }];
        _activity.hidesWhenStopped = YES;
    }
    return _activity;
}


@end
