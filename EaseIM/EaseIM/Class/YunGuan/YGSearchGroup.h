//
//  YGSearchGroup.h
//  EaseIM
//
//  Created by liu001 on 2022/7/21.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <HyphenateChat/HyphenateChat.h>

NS_ASSUME_NONNULL_BEGIN

@interface YGSearchGroup : NSObject
@property (nonatomic, assign) BOOL isGroupMember;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupId;

@end

NS_ASSUME_NONNULL_END
