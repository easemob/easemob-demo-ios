//
//  AgoraCustomCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/22.
//  Copyright © 2021 easemob. All rights reserved.
//
#define kAvatarImageHeight 44.0

#import "BQCustomCell.h"

@interface BQCustomCell ()
@property (nonatomic, strong) UIView* bottomLine;
@property (nonatomic, strong)UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation BQCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    if ([EMDemoOptions sharedOptions].isJiHuApp) {
            self.contentView.backgroundColor = ViewCellBgBlackColor;
    }else {
            self.contentView.backgroundColor = ViewCellBgWhiteColor;
    }

        [self prepare];
        [self placeSubViews];
    }
    return self;
}

- (void)tapAction {
    if (self.tapCellBlock) {
        self.tapCellBlock();
    }
}

- (void)prepare {

}

- (void)placeSubViews {
    
}

- (void)updateWithObj:(id)obj {
    
}


+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}


+ (CGFloat)height {
    return 64.0f;
}


#pragma mark getter and setter
- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
//        _iconImageView.layer.cornerRadius = kAvatarImageHeight * 0.5;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.masksToBounds = YES;
    }
    return _iconImageView;
}


- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = NFont(14.0);
        
        if ([EMDemoOptions sharedOptions].isJiHuApp) {
            _nameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
        }else {
            _nameLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        }

        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    }
    return _nameLabel;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = UIView.new;
if ([EMDemoOptions sharedOptions].isJiHuApp) {
        _bottomLine.backgroundColor = [UIColor colorWithHexString:@"#1C1C1C"];
}else {
        _bottomLine.backgroundColor = [UIColor colorWithHexString:@"#DADADA"];
}
    }
    return _bottomLine;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _tapGestureRecognizer;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.contentView.backgroundColor = COLOR_HEX(0x333333);
    }else {
if ([EMDemoOptions sharedOptions].isJiHuApp) {
        self.contentView.backgroundColor = ViewCellBgBlackColor;
}else {
        self.contentView.backgroundColor = ViewCellBgWhiteColor;
}

    }
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.contentView.backgroundColor = COLOR_HEX(0x333333);
    }else {
if ([EMDemoOptions sharedOptions].isJiHuApp) {
        self.contentView.backgroundColor = ViewCellBgBlackColor;
}else {
        self.contentView.backgroundColor = ViewCellBgWhiteColor;

}

    }

}


@end

#undef kAvatarImageHeight

