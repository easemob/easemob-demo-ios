//
//  BQGroupSearchCell.h
//  EaseIM
//
//  Created by liu001 on 2022/7/9.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQCustomCell.h"

typedef enum : NSUInteger {
    BQGroupUserTypeNone,
    BQGroupUserTypeServicer,
    BQGroupUserTypeCustomer,
} BQGroupUserType;

NS_ASSUME_NONNULL_BEGIN

@interface BQGroupSearchCell : BQCustomCell

@property (nonatomic, copy) void (^servicerBlock)(NSString *userId);
@property (nonatomic, copy) void (^customerBlock)(NSString *userId);
@property (nonatomic, assign) BQGroupUserType groupUserType;


@end

NS_ASSUME_NONNULL_END
