//
//  EMGroupMemberNickNameViewController.h
//  EaseIM
//
//  Created by 朱继超 on 2023/1/17.
//  Copyright © 2023 朱继超. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMGroupMemberNickNameViewController : UIViewController

@property (copy,nonnull) void(^changeResult)(NSString *nickName);

@property (nonatomic) NSString *nickName;

- (instancetype)initWithGroupId:(NSString *)groupId nickName:(NSString *_Nullable)name;

@end

NS_ASSUME_NONNULL_END
