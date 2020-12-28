//
//  EaseCallManager+Private.h
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/12/3.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import "EaseCallManager.h"

@interface EaseCallManager (Private)
- (void)acceptWithType:(EaseCallType)type;
- (void)hangupWithType:(EaseCallType)type;
- (void)inviteMemberAction;
- (void)enableVideoAction:(BOOL)aEnable;
- (void)muteAction:(BOOL)aMute;
- (void)switchCameraAction;
- (NSString*)getNickNameFromUID:(NSString*)uId;
@end /* EaseCallManager_Private_h */
