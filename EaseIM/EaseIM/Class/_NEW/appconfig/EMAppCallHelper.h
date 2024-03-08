//
//  EMAppCallHelper.h
//  EaseIM
//
//  Created by yangjian on 2022/7/27.
//  Copyright © 2022 yangjian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserInfoStore.h"
#import "ConfInviteUsersViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SingleCallController.h"
#import "ConferenceController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMAppCallHelper : NSObject
<
EaseCallDelegate
>

+ (instancetype)shared;


@end

NS_ASSUME_NONNULL_END
