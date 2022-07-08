//
//  BQGroupMemberCell.h
//  EaseIM
//
//  Created by liu001 on 2022/7/7.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface BQGroupMemberCell : BQCustomCell
@property (nonatomic, copy) void (^addMemberBlock)(void);
@property (nonatomic, copy) void (^moreMemberBlock)(void);

+ (CGFloat)cellHeightWithObj:(id)obj;

@end

NS_ASSUME_NONNULL_END
