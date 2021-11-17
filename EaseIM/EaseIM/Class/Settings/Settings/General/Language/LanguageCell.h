//
//  LanguageCell.h
//  EaseIM
//
//  Created by lixiaoming on 2021/11/11.
//  Copyright © 2021 lixiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LanguageCell : UITableViewCell
@property (nonatomic,strong) NSString* nativeName;
@property (nonatomic,strong) NSString* language;
@property (nonatomic,strong) UIImageView* checkView;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier;
@end

NS_ASSUME_NONNULL_END
