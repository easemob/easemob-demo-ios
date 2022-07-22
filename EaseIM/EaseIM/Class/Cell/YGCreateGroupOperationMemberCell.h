//
//  YGCreateGroupOperationMemberCell.h
//  EaseIM
//
//  Created by liu001 on 2022/7/21.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface YGCreateGroupOperationMemberCell : BQCustomCell
@property (nonatomic, copy) void (^addMemberBlock)(void);

+ (CGFloat)cellHeightWithObj:(id)obj;

@end

NS_ASSUME_NONNULL_END