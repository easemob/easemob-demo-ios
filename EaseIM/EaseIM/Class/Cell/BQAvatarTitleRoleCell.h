//
//  BQAvatarTitleRoleCell.h
//  EaseIM
//
//  Created by liu001 on 2022/7/8.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface BQAvatarTitleRoleCell : BQCustomCell

- (void)updateWithObj:(id)obj isOwner:(BOOL)isOwner;

@end

NS_ASSUME_NONNULL_END
