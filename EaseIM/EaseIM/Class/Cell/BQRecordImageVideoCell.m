//
//  BQRecordImageVideoCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/11.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQRecordImageVideoCell.h"

@implementation BQRecordImageVideoCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubViews];
    }
    return self;
}


- (void)placeAndLayoutSubViews {
    [self.contentView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

}


- (void)updateWithObj:(id)obj {
    NSString *urlString = (NSString *)obj;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:ImageWithName(@"")];
}


+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}


#pragma mark getter and setter
- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.layer.cornerRadius = 8.0f;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.masksToBounds = YES;
    }
    
    return _iconImageView;
}

@end

