//
//  LanguageCell.m
//  EaseIM
//
//  Created by lixiaoming on 2021/11/11.
//  Copyright © 2021 lixiaoming. All rights reserved.
//

#import "LanguageCell.h"

@interface LanguageCell ()
@end

@implementation LanguageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super  initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self _setupSubViews];
    }
    return self;
}

- (void)_setupSubViews
{
    self.checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"languagechecked"]];
    [self.contentView addSubview:self.checkView];
    self.checkView.frame = CGRectMake(self.contentView.bounds.size.width, 10, 20, 20);
}

@end
