//
//  ImageCodeView.m
//  EaseIM
//
//  Created by li xiaoming on 2022/8/9.
//  Copyright © 2022 li xiaoming. All rights reserved.
//

#import "ImageCodeView.h"

@interface ImageCodeView ()
@property (nonatomic,strong) NSArray<UILabel*>* lables;
@end

@implementation ImageCodeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
    self.backgroundColor = [UIColor colorWithRed:250 green:255 blue:240 alpha:1.0];
    [self updateBackLines];
}

- (void)showImageCodes
{
    
}

- (void)updateBackLines {
    NSInteger width = self.bounds.size.width;
    NSInteger height = self.bounds.size.height;
    for (NSInteger i = 0; i < 5; i++) {
        UIBezierPath* path = [UIBezierPath bezierPath];
        CGFloat startX = arc4random() % width;
        CGFloat startY = arc4random() % height;
        [path moveToPoint:CGPointMake(startX, startY)];
        CGFloat endX = arc4random() % width;
        CGFloat endY = arc4random() % height;
        [path addLineToPoint:CGPointMake(endX, endY)];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.strokeColor = [UIColor colorWithRed:arc4random()%256 green:arc4random()%256 blue:arc4random()%256 alpha:1.0].CGColor;
        layer.lineWidth = 0.4f;
        layer.strokeEnd = 1;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.path = path.CGPath;
        [self.layer addSublayer:layer];
    }
}

@end
