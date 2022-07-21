//
//  YGGroupApplyApprovalCell.h
//  EaseIM
//
//  Created by liu001 on 2022/7/20.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQCustomCell.h"
//群组申请审批

NS_ASSUME_NONNULL_BEGIN

@interface YGGroupApplyApprovalCell : BQCustomCell
@property (nonatomic, copy) void (^approvalBlock)(BOOL agree);


@end

NS_ASSUME_NONNULL_END
