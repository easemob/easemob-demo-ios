//
//  EaseCallManager.h
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/11/18.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EaseCallConfig.h"
#import <Hyphenate/Hyphenate.h>

typedef NS_ENUM(NSInteger,EaseCallType) {
    EaseCallType1v1Audio,
    EaseCallType1v1Video,
    EaseCallTypeMulti
};


@protocol EaseCallDelegate <NSObject>
// 结束时通话时长
- (void)callDidEnd:(EMCallEndReason)reason time:(int)tm type:(EaseCallType)type;
// 多人音视频邀请按钮的回调
- (void)multiCallDidInvitingWithCurVC:(UIViewController*_Nonnull)vc excludeUsers:(NSArray<NSString*> *_Nullable)users;
// 振铃时增加回调
- (void)callDidReceive:(EaseCallType)aType inviter:(NSString*_Nonnull)user;
@end

NS_ASSUME_NONNULL_BEGIN

@interface EaseCallManager : NSObject<EMChatManagerDelegate,EMConferenceManagerDelegate>
+ (instancetype)sharedManager;
- (void)initWithConfig:(EaseCallConfig*)aConfig delegate:(id<EaseCallDelegate>)aDelegate;
// 每次通话时的配置（标题、振铃文件、是否振动）,通话类型（语音、视频）
- (void)startSingleCallWithUId:(NSString*)uId type:(EMCallType)aType completion:(void (^)(EMError*))aCompletionBlock;
// 多人会议邀请
- (void)startInviteUsers:(NSArray<NSString*>*)aUsers  completion:(void (^)(EMError*))aCompletionBlock;
// 获取配置
- (EaseCallConfig*)getEaseCallConfig;
@end

NS_ASSUME_NONNULL_END
