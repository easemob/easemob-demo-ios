//
//  BQRecordImageVideoCell.h
//  EaseIM
//
//  Created by liu001 on 2022/7/11.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BQRecordImageVideoCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
- (void)updateWithObj:(id)obj;

+ (NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
