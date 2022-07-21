//
//  YGAvatarTitleAccessCell.h
//  EaseIM
//
//  Created by liu001 on 2022/7/20.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface YGAvatarTitleAccessCell : BQCustomCell
@property (nonatomic, assign) BOOL isGroupMember;
@property (nonatomic, copy) void (^accessBlock)(NSString *groupId);

@end

NS_ASSUME_NONNULL_END
