//
//  EaseCallManager.m
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/11/18.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import "EaseCallManager.h"
#import "EaseCallSingleViewController.h"
#import "EaseCallMultiViewController.h"
#import "EaseCallManager+Private.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Masonry/Masonry.h>

@interface EaseCallManager ()
@property (nonatomic) EaseCallType callType;
@property (nonatomic) EaseCallMultiViewController* multiVC;
@property (nonatomic) EaseCallSingleViewController* singleVC;
@property (nonatomic) NSMutableDictionary* inviteTimerDic;
@property (nonatomic) NSMutableDictionary* noSubStreamsDic;
@property (nonatomic) NSTimer* ringTimer;
@property (nonatomic) EaseCallStreamView* localView;
@property (nonatomic) EaseCallStreamView* remoteView;
@property (nonatomic) int memberCount;
@property (nonatomic) NSMutableArray* members;
@property (nonatomic) int inviteeCount;
@property (nonatomic) NSMutableArray* invitees;
@property (nonatomic) NSString* pubId;
@property (nonatomic) EaseCallConfig* config;
@property (nonatomic) EMCallConference* conference;
@property (nonatomic,weak) id<EaseCallDelegate> delegate;
@property (nonatomic) NSString* callFrom;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) dispatch_queue_t workQueue;
@property (nonatomic) EMCallEndReason endReason;
@property (nonatomic) NSString* confrPwd;
@property (nonatomic) NSMutableSet* unShowPlaces;
@end

@implementation EaseCallManager
static EaseCallManager *easeCallManager = nil;
static NSString* kPassword = @"123456";
static NSString* kConfrId = @"confrId";
static NSString* kConfrPwd = @"confrPwd";
static NSString* kCallType = @"callType";
static NSString* kResult = @"result";
static NSString* kInviteAttrHead = @"invitee_";

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        easeCallManager = [[EaseCallManager alloc] init];
        easeCallManager.delegate = nil;
        easeCallManager.conference = nil;
        easeCallManager.pubId = nil;
        [[EMClient sharedClient].chatManager addDelegate:easeCallManager delegateQueue:nil];
        [[EMClient sharedClient].conferenceManager addDelegate:easeCallManager delegateQueue:nil];
    });
    return easeCallManager;
}

- (void)initWithConfig:(EaseCallConfig*)aConfig delegate:(id<EaseCallDelegate>)aDelegate
{
    self.delegate= aDelegate;
    _workQueue = dispatch_queue_create("EMMediaManager.WorkQ", DISPATCH_QUEUE_SERIAL);
    if(aConfig) {
        self.config = aConfig;
    }else{
        self.config = [[EaseCallConfig alloc] init];
    }
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.config.ringFileUrl error:nil];
}

- (EaseCallConfig*)getEaseCallConfig
{
    return self.config;
}

- (NSMutableArray*)members
{
    if(!_members) {
        _members = [NSMutableArray array];
    }
    return  _members;
}

- (NSMutableArray*)invitees
{
    if(!_invitees) {
        _invitees = [NSMutableArray array];
    }
    return  _invitees;
}

- (NSMutableSet*)unShowPlaces
{
    if(!_unShowPlaces) {
        _unShowPlaces = [NSMutableSet set];
    }
    return _unShowPlaces;
}

- (void)resetRes
{
    self.memberCount = 0;
    self.inviteeCount = 0;
    [self.members removeAllObjects];
    [self.invitees removeAllObjects];
    for (NSTimer*tm in self.inviteTimerDic.allValues) {
        if(tm) {
            [tm invalidate];
        }
    }
    [self.inviteTimerDic removeAllObjects];
    [self.noSubStreamsDic removeAllObjects];
    if(self.ringTimer) {
        [self.ringTimer invalidate];
        self.ringTimer = nil;
    }
}

- (void)startInviteUsers:(NSArray<NSString*>*)aUsers  completion:(void (^)(EMError*))aCompletionBlock{
    __weak typeof(self) weakself = self;
    dispatch_async(self.workQueue, ^(void){
        if(weakself.conference) {
            if(aCompletionBlock) {
                aCompletionBlock([EMError errorWithDescription:@"busy" code:EMErrorCallBusy]);
            }
        }
        
        void (^block)() = ^() {
            for (NSString* uId in aUsers) {
                [weakself setInviteConfrAttribute:@[uId]];
            }
        };
        // 1、创建并加入会议
        if(!weakself.conference) {
            [weakself resetRes];
            [[EMClient sharedClient].conferenceManager createAndJoinConferenceWithType:EMConferenceTypeCommunication password:kPassword completion:^(EMCallConference *aCall, NSString *aPassword, EMError *aError) {
                if(!aError) {
                    weakself.callType = EaseCallTypeMulti;
                    weakself.conference = aCall;
                    weakself.confrPwd = kPassword;
                    // 2、打开多人页面
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakself.multiVC = [[EaseCallMultiViewController alloc] init];
                        if(weakself.multiVC) {
                            weakself.multiVC.modalPresentationStyle = UIModalPresentationFullScreen;
                            UIViewController *rootViewController = [[UIApplication sharedApplication].delegate window].rootViewController;

                            [rootViewController presentViewController:weakself.multiVC animated:NO completion:^(void){
                                // 3、发流
                                EMCallLocalView *localView = [[EMCallLocalView alloc] init];
                                //视频通话页面缩放方式
                                localView.scaleMode = EMCallViewScaleModeAspectFill;
                                void (^pubblock)(NSString *aPubStreamId, EMError *aError) = ^(NSString *aPubStreamId, EMError *aError) {
                                    if (aError) {
                                        if (aCompletionBlock) {
                                            aCompletionBlock(aError);
                                        }
                                        return ;
                                    }else{
                                        weakself.pubId = aPubStreamId;
                                        
                                        [weakself.multiVC setLocalVideoView:localView enableVideo:NO];
                                        // 4、设置全局会议属性
                                        [weakself setGlobalConfrAttribute:aCall];
                                        
                                        // 5、设置邀请会议属性,并发送邀请消息
                                        block();
                                        // 7、回调
                                        if(aCompletionBlock) {
                                            aCompletionBlock(nil);
                                        }
                                    }
                                };
                                [self pubStreamWithLocalView:localView completion:pubblock];
                            }];
                            
                        }
                    });
                    
                }else{
                    if(aCompletionBlock) {
                        aCompletionBlock(aError);
                    }
                }
            }];
        }else{
            block();
        }
    });
    
}

- (NSString*)getNickNameFromUID:(NSString*)uId
{
    if(self.config.users) {
        EaseCallUser* user = [self.config.users objectForKey:uId];
        if(user && [user.nickName length] > 0)
            return user.nickName;
    }
    return uId;
}

- (void)startSingleCallWithUId:(NSString*)uId type:(EMCallType)aType completion:(void (^)(EMError*))aCompletionBlock; {
    __weak typeof(self) weakself = self;
    dispatch_async(weakself.workQueue, ^(void){
        if(weakself.conference) {
            if(aCompletionBlock) {
                aCompletionBlock([EMError errorWithDescription:@"busy" code:EMErrorCallBusy]);
            }
        }
        
        // 1、创建并加入会议
        [weakself resetRes];
        [[EMClient sharedClient].conferenceManager createAndJoinConferenceWithType:EMConferenceTypeCommunication password:kPassword completion:^(EMCallConference *aCall, NSString *aPassword, EMError *aError) {
            if(!aError) {
                weakself.callType = aType == EMCallTypeVoice ? EaseCallType1v1Audio:EaseCallType1v1Video;
                weakself.conference = aCall;
                weakself.confrPwd = kPassword;
                // 2、打开1v1页面
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakself.singleVC = [[EaseCallSingleViewController alloc] initWithisCaller:YES type:self.callType remoteName:uId];
                    if(weakself.singleVC) {
                        
                        weakself.singleVC.modalPresentationStyle = UIModalPresentationFullScreen;
                        UIViewController *rootViewController = [[UIApplication sharedApplication].delegate window].rootViewController;

                        [rootViewController presentViewController:weakself.singleVC animated:NO completion:^{
                            // 3、发流
                            EMCallLocalView *aDisplayView = [[EMCallLocalView alloc] init];
                            //视频通话页面缩放方式
                            aDisplayView.scaleMode = EMCallViewScaleModeAspectFill;
                            
                            void (^pubblock)(NSString *aPubStreamId, EMError *aError) = ^(NSString *aPubStreamId, EMError *aError) {
                                if (aError) {
                                    if (aCompletionBlock) {
                                        aCompletionBlock(aError);
                                    }
                                    return ;
                                }else{
                                    weakself.localView = [[EaseCallStreamView alloc] init];
                                    weakself.localView.displayView = aDisplayView;
                                    [weakself.localView addSubview:aDisplayView];
                                    [weakself.localView sendSubviewToBack:aDisplayView];
                                    [aDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
                                        make.edges.equalTo(weakself.localView);
                                    }];
                                    weakself.singleVC.localView = weakself.localView;
                                    weakself.pubId = aPubStreamId;
                                    
                                    // 4、设置全局会议属性
                                    [weakself setGlobalConfrAttribute:aCall];
                                    // 5、设置邀请会议属性,并发送邀请消息
                                    [weakself setInviteConfrAttribute:@[uId]];
                                    // 6、回调
                                    if(aCompletionBlock) {
                                        aCompletionBlock(nil);
                                    }
                                }
                            };
                            [self pubStreamWithLocalView:aDisplayView completion:pubblock];
                            
                        }];
                    }
                });
                
            }else{
                if(aCompletionBlock) {
                    aCompletionBlock(aError);
                }
            }
        }];
    });
}

- (void)setGlobalConfrAttribute:(EMCallConference*)aCall
{
    if(aCall) {
        [[EMClient sharedClient].conferenceManager setConferenceAttribute:kConfrId value:aCall.confId completion:^(EMError *aError) {
            
        }];
    }
}

- (NSMutableDictionary*)inviteTimerDic
{
    if(!_inviteTimerDic) {
        _inviteTimerDic = [NSMutableDictionary dictionary];
    }
    return _inviteTimerDic;
}

- (void)setInviteConfrAttribute:(NSArray<NSString*>* )aArrayUsers
{
    for (NSString* key in aArrayUsers) {
        // 设置邀请会议属性
        NSString* attributeKey = [NSString stringWithFormat:@"%@%@",kInviteAttrHead,key];
        [[EMClient sharedClient].conferenceManager setConferenceAttribute:attributeKey value:@"{status:calling}" completion:^(EMError *aError) {
            
        }];
        //发送邀请消息
        EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"邀请您进行通话"];
        NSString *from = [[EMClient sharedClient] currentUsername];
        NSString *to = key;
        EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:@{kConfrId:self.conference.confId,kConfrPwd:self.confrPwd,kCallType:[NSNumber numberWithInt:self.callType]}];
        message.chatType = EMChatTypeChat;
        [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
    }
}

- (void)pubStreamWithLocalView:(EMCallLocalView *)localView completion:(void (^)(NSString *aPubStreamId, EMError *aError))aCompletionBlock
{
    EMStreamParam *pubConfig = [[EMStreamParam alloc] init];
    pubConfig.streamName = [EMClient sharedClient].currentUsername;
    if(self.callType == EaseCallType1v1Video)
        pubConfig.enableVideo = YES;
    else
        pubConfig.enableVideo = NO;
    pubConfig.isMute = NO;
    //显示本地视频的页面
    pubConfig.localView = localView;
    [[EMClient sharedClient].conferenceManager publishConference:self.conference streamParam:pubConfig completion:aCompletionBlock];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError* error = nil;
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if(error != nil)
        return;
    [audioSession setActive:YES error:&error];
    if(error != nil)
        return;
}

- (void)acceptWithType:(EaseCallType)type
{
    [self stopSound];
    if(self.conference && [self.pubId length] == 0) {
        // 点击接听，发流
        if(type != EaseCallTypeMulti) {
            self.callType = type;
            self.remoteView = [[EaseCallStreamView alloc] init];
            EMCallLocalView *localView = [[EMCallLocalView alloc] init];
            self.localView = [[EaseCallStreamView alloc] init];
            self.localView.displayView = localView;
            //视频通话页面缩放方式
            localView.scaleMode = EMCallViewScaleModeAspectFill;
            void (^block)(NSString *aPubStreamId, EMError *aError) = ^(NSString *aPubStreamId, EMError *aError) {
                if (!aError) {
                    self.pubId = aPubStreamId;
                    self.singleVC.localView = self.localView;
                    [self.singleVC setLocalDisplayView:localView enableVideo:(type == EaseCallType1v1Video)];
                    if(self.noSubStreamsDic.count > 0) {
                        NSString* key = [self.noSubStreamsDic.allKeys objectAtIndex:0];
                        //订阅流
                        EMCallRemoteView* remoteView = [[EMCallRemoteView alloc] init];
                        self.remoteView.displayView = remoteView;
                        EMCallStream* stream = [self.noSubStreamsDic objectForKey:key];
                        [[[EMClient sharedClient] conferenceManager] subscribeConference:self.conference streamId:key remoteVideoView:remoteView completion:^(EMError *aError) {
                            
                            self.singleVC.remoteView = self.remoteView;
                            [self.singleVC setRemoteDisplayView:remoteView enableVideo:stream.enableVideo];
                        }];
                    }
                }
            };
            [self pubStreamWithLocalView:localView completion:block];
        }else{
            
            EMCallLocalView *localView = [[EMCallLocalView alloc] init];
            //视频通话页面缩放方式
            localView.scaleMode = EMCallViewScaleModeAspectFill;
            void (^block)(NSString *aPubStreamId, EMError *aError) = ^(NSString *aPubStreamId, EMError *aError) {
                if (!aError) {
                    self.pubId = aPubStreamId;
                    [self.multiVC setLocalVideoView:localView enableVideo:NO];
                    for(NSString* key in self.noSubStreamsDic.allKeys) {
                        EMCallStream* value = [self.noSubStreamsDic objectForKey:key];
                        //订阅流
                        EMCallRemoteView* remoteView = [[EMCallRemoteView alloc] init];
                        [[[EMClient sharedClient] conferenceManager] subscribeConference:self.conference streamId:key remoteVideoView:remoteView completion:^(EMError *aError) {
                            NSString* uId = [value.memberName substringFromIndex:([EMClient sharedClient].options.appkey.length+1)];
                            [self.multiVC addRemoteView:remoteView streamId:key member:uId enableVideo:value.enableVideo];
                            [self.multiVC setRemoteEnableVideo:value.enableVideo streamId:key];
                        }];
                    }
                }
            };
            [self pubStreamWithLocalView:localView completion:block];
        }
    }
}

- (void)exitNotify:(EMCallEndReason)reason time:(int)tm
{
    [self stopSound];
    if(self.delegate && [self.delegate respondsToSelector:@selector(callDidEnd:time:type:)]) {
        [self.delegate callDidEnd:reason time:tm type:self.callType];
    }
    self.endReason = EMCallEndReasonHangup;
}

- (void)exitWithType:(EaseCallType)type
{
    __weak typeof(self) weakself = self;
    if(type != EaseCallTypeMulti) {
        void (^block)(EMError*) = ^(EMError*err){
            weakself.conference = nil;
            weakself.pubId = nil;
            if(weakself.singleVC)
                [weakself.singleVC dismissViewControllerAnimated:NO completion:^{
                    weakself.singleVC = nil;
                }];
            
        };
        if(self.conference.role == EMConferenceRoleAdmin) {
            [[[EMClient sharedClient] conferenceManager] destroyConferenceWithId:weakself.conference.confId completion:block];
        }else{
            [[[EMClient sharedClient] conferenceManager] leaveConference:weakself.conference completion:block];
        }
        
    }else{
        void (^block)(EMError*) = ^(EMError*err){
            weakself.conference = nil;
            weakself.pubId = nil;
            if(self.multiVC.presentedViewController)
                [self.multiVC.presentedViewController dismissViewControllerAnimated:YES completion:^{
                    
                }];
            [weakself.multiVC dismissViewControllerAnimated:NO completion:^{
                weakself.multiVC = nil;
            }];
        };
        [[[EMClient sharedClient] conferenceManager] leaveConference:weakself.conference completion:block];
    }
    
}

- (void)enableVideoAction:(BOOL)aEnable
{
    [[[EMClient sharedClient] conferenceManager] updateConference:self.conference enableVideo:aEnable];
}
- (void)muteAction:(BOOL)aMute
{
    [[[EMClient sharedClient] conferenceManager] updateConference:self.conference isMute:aMute];
}
- (void)switchCameraAction
{
    [[[EMClient sharedClient] conferenceManager] updateConferenceWithSwitchCamera:self.conference];
}
- (void)hangupWithType:(EaseCallType)type
{
    __weak typeof(self) weakself = self;
    [self stopSound];
    [self resetRes];
    if([weakself.pubId length] == 0) {
        // 删除会议属性
        [[[EMClient sharedClient] conferenceManager] deleteAttributeWithKey:[NSString stringWithFormat:@"%@%@",kInviteAttrHead,[EMClient sharedClient].currentUsername] completion:^(EMError *aError) {
            [weakself exitWithType:type];
        }];
        return;
    }
    int timeLenth = type == EaseCallTypeMulti?self.multiVC.timeLength:self.singleVC.timeLength;
    [self exitNotify:self.endReason time:timeLenth];
    [self exitWithType:type];
}

- (void)inviteMemberAction
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(multiCallDidInvitingWithCurVC:excludeUsers:)]) {
        NSMutableArray* array = [self.invitees mutableCopy];
        [array addObjectsFromArray:self.members];
        
        [self.delegate multiCallDidInvitingWithCurVC:self.multiVC excludeUsers:array];
    }
}

- (void)_timeoutBeforeInviteeAnswered:(NSTimer *)timer
{
    NSLog(@"_timeoutBeforeInviteeAnswered");
    NSString *uId = (NSString *)[timer userInfo]; //必须放在本timer关闭之前使用，不然会出现野指针错误
    if(uId && [uId length] > 0) {
        [self stopInviting:uId];
    }
    self.endReason = EMCallEndReasonNoResponse;
    if(self.callType != EaseCallTypeMulti) {
        [self.singleVC hangupAction];
    }
}

#pragma mark - EMChatManagerDelegate
- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *msg in aMessages) {
        [self _parseMsg:msg];
    }
}

- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages
{
    
}

- (void)_parseMsg:(EMMessage*)aMsg
{
    if(![aMsg.to isEqualToString:[EMClient sharedClient].currentUsername])
        return;
    NSDictionary*ext = aMsg.ext;
    NSNumber* type = [ext objectForKey:kCallType];
    NSString* confrId = [ext objectForKey:kConfrId];
    NSString* pwd = [ext objectForKey:kConfrPwd];
    NSString* result = [ext objectForKey:kResult];
    self.callFrom = aMsg.from;
    if([confrId length] > 0 && [pwd length] > 0 && type) {
        // 1、收到通话请求
        if(self.conference) {
            // 正忙
            if(![self.conference.confId isEqualToString:confrId])
                [self _sendBusyResponse:aMsg.from confrId:confrId];
            return;
        }
        // 2、加入会议
        __weak typeof(self) weakself = self;
        [weakself resetRes];
        [[[EMClient sharedClient] conferenceManager] joinConferenceWithConfId:confrId password:pwd completion:^(EMCallConference *aCall, EMError *aError) {
            if(!aError) {
                weakself.callType = type.intValue;
                weakself.conference = aCall;
                weakself.confrPwd = pwd;
                // 启动接听定时器
                weakself.ringTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(_timeoutRecvInviteAttr:) userInfo:nil repeats:NO];
            }else{
                if(aError.code == EMErrorCallAlreadyJoined && ![weakself.conference.confId isEqualToString:confrId]) {
                    [weakself _sendBusyResponse:aMsg.from confrId:confrId];
                }
            }
            
        }];
    }
    if([confrId length] > 0 && [result length] > 0 ) {
        if([result isEqualToString:@"busy"]) {
            // 收到对方忙碌的消息
            [self stopInviting:aMsg.from];
            if(self.callType != EaseCallTypeMulti) {
                self.endReason = EMCallEndReasonBusy;
                [self hangupWithType:self.callType];
            }
        }
    }
}

- (void)stopInviting:(NSString*)uId
{
    // 结束邀请定时器
    NSTimer* timer = [self.inviteTimerDic objectForKey:uId];
    if(timer) {
        [timer invalidate];
        timer = nil;
        [self.inviteTimerDic removeObjectForKey:uId];
    }
    // 删除会议属性
    [[[EMClient sharedClient] conferenceManager] deleteAttributeWithKey:[NSString stringWithFormat:@"%@%@",kInviteAttrHead,uId] completion:^(EMError *aError) {
                    
    }];
}

- (void)_timeoutRecvInviteAttr:(NSTimer*)timer
{
    NSLog(@"_timeoutRecvInviteAttr");
    [self hangupWithType:self.callType];
}

- (void)_sendBusyResponse:(NSString*)uId confrId:(NSString*)confrId
{
    //发送邀请消息
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"正在通话中"];
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSString *to = uId;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:@{kConfrId:self.conference.confId,kResult:@"busy"}];
    message.chatType = EMChatTypeChat;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}

#pragma mark EMConferenceDelegate

- (void)memberDidJoin:(EMCallConference *)aConference
               member:(EMCallMember *)aMember
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 加入会议", aMember.memberName];
        self.memberCount++;
        NSString* uId = [aMember.memberName substringFromIndex:([EMClient sharedClient].options.appkey.length+1)];
        if(![self.members containsObject:uId])
            [self.members addObject:uId];
    }
}

- (void)memberDidLeave:(EMCallConference *)aConference
                member:(EMCallMember *)aMember
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 离开会议", aMember.memberName];
        self.memberCount--;
        NSString* uId = [aMember.memberName substringFromIndex:([EMClient sharedClient].options.appkey.length+1)];
        [self.members removeObject:uId];
        [self checkIfNeedExit];
    }
}
//有新的数据流上传
- (void)streamDidUpdate:(EMCallConference *)aConference
              addStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        // 收到同名用户发流事件
        NSString* currentMemberName = [NSString stringWithFormat:@"%@_%@",[EMClient sharedClient].options.appkey,[EMClient sharedClient].currentUsername];
        if([aStream.memberName isEqualToString:currentMemberName]) {
            // 退出会议
            if(self.ringTimer) {
                [self.ringTimer invalidate];
                self.ringTimer = nil;
            }
            [self exitNotify:EMCallEndReasonLoginOtherDevice time:0];
            [self hangupWithType:self.callType];
        }else{
            if([self.pubId length] > 0) {
                // 已经接听发流，直接订阅流
                if(self.callType != EaseCallTypeMulti) {
                    EMCallRemoteView* aDisplayView = [[EMCallRemoteView alloc] init];
                    aDisplayView.scaleMode = EMCallViewScaleModeAspectFill;
                    [[[EMClient sharedClient] conferenceManager] subscribeConference:self.conference streamId:aStream.streamId remoteVideoView:aDisplayView completion:^(EMError *aError) {
                        if(!aError) {
                            EaseCallStreamView*remoteStreamView = [[EaseCallStreamView alloc] init];
                            self.singleVC.remoteView = remoteStreamView;
                            [self.singleVC setRemoteDisplayView:aDisplayView enableVideo:aStream.enableVideo];
                        }
                    }];
                }else{
                    EMCallRemoteView* aDisplayView = [[EMCallRemoteView alloc] init];
                    aDisplayView.scaleMode = EMCallViewScaleModeAspectFill;
                    [[[EMClient sharedClient] conferenceManager] subscribeConference:self.conference streamId:aStream.streamId remoteVideoView:aDisplayView completion:^(EMError *aError) {
                        if(!aError) {
                            NSString* uId = [aStream.memberName substringFromIndex:([EMClient sharedClient].options.appkey.length+1)];
                            [self.multiVC addRemoteView:aDisplayView streamId:aStream.streamId member:uId enableVideo:aStream.enableVideo];
                            [self.multiVC setRemoteEnableVideo:aStream.enableVideo streamId:aStream.streamId];
                        }
                    }];
                }
            }else{
                // 尚未接听，将流存储下来，接听发流后再订阅
                [self.noSubStreamsDic setObject:aStream forKey:aStream.streamId];
            }
        }
    }
}

- (NSMutableDictionary*)noSubStreamsDic
{
    if(!_noSubStreamsDic) {
        _noSubStreamsDic = [NSMutableDictionary dictionary];
    }
    return _noSubStreamsDic;
}

- (void)streamDidUpdate:(EMCallConference *)aConference
           removeStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        if(self.pubId) {
            //已经加入发流，移除显示
            if(self.callType == EaseCallTypeMulti) {
                [self.multiVC removeRemoteViewForStreamId:aStream.streamId];
            }
        }else{
            [self.noSubStreamsDic removeObjectForKey:aStream.streamId];
            
        }
    }
}

- (void)conferenceDidEnd:(EMCallConference *)aConference
                  reason:(EMCallEndReason)aReason
                   error:(EMError *)aError
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        if(aReason == EMCallEndReasonLoginOtherDevice) {
            // 其他设备接听发流，被踢
            if(self.ringTimer) {
                [self.ringTimer invalidate];
                self.ringTimer = nil;
            }
            self.endReason = EMCallEndReasonLoginOtherDevice;
        }
        [self resetRes];
        
        [self exitNotify:self.endReason time:[self getConfrTime]];
        self.conference = nil;
        self.pubId = nil;
        if(self.callType != EaseCallTypeMulti) {
            [self.singleVC dismissViewControllerAnimated:NO completion:^{
                self.singleVC = nil;
            }];
        }else{
            if(self.multiVC.presentedViewController)
                [self.multiVC.presentedViewController dismissViewControllerAnimated:YES completion:^{
                    
                }];
            [self.multiVC dismissViewControllerAnimated:NO completion:^{
                self.multiVC = nil;
            }];
        }
    }
}

- (int)getConfrTime
{
    if(self.pubId)
        return 0;
    if(self.callType == EaseCallTypeMulti)
        return self.multiVC.timeLength;
    return 0;
}
//数据流有更新（是否静音，视频是否可用）(有人静音自己/关闭视频)
- (void)streamDidUpdate:(EMCallConference *)aConference
                 stream:(EMCallStream *)aStream
{
    if (![aConference.callId isEqualToString:self.conference.callId] || aStream == nil) {
        return;
    }
    if(self.callType != EaseCallTypeMulti) {
        if(self.singleVC)
        {
            if(!aStream.enableVideo)
            {
                [self.singleVC updateToVoice];
            }
            self.singleVC.remoteView.enableVideo = aStream.enableVideo;
            if( self.singleVC.remoteView.enableVoice != aStream.enableVoice)
               [self.singleVC showTip:aStream.enableVoice];
            self.singleVC.remoteView.enableVoice = aStream.enableVoice;
        }
    }else{
        if(self.multiVC) {
            [self.multiVC setRemoteMute:!aStream.enableVoice streamId:aStream.streamId];
            [self.multiVC setRemoteEnableVideo:aStream.enableVideo streamId:aStream.streamId];
        }
    }
    
}
//数据流已经开始传输数据
- (void)streamStartTransmitting:(EMCallConference *)aConference
                       streamId:(NSString *)aStreamId
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        if(self.callType == EaseCallType1v1Video) {
            if([aStreamId isEqualToString:self.pubId]) {
                self.singleVC.localView.status = StreamStatusConnected;
            }else{
                self.singleVC.remoteView.status = StreamStatusConnected;
            }
        }
    }
}

- (void)conferenceNetworkDidChange:(EMCallConference *)aSession
                            status:(EMCallNetworkStatus)aStatus
{
    NSString *str = @"";
    switch (aStatus) {
        case EMCallNetworkStatusNormal:
            str = @"网路正常";
            break;
        case EMCallNetworkStatusUnstable:
            str = @"网路不稳定";
            break;
        case EMCallNetworkStatusNoData:
            str = @"网路已断开";
            break;
            
        default:
            break;
    }
}
//用户A用户B在同一个会议中，用户A开始说话时，用户B会收到该回调
- (void)conferenceSpeakerDidChange:(EMCallConference *)aConference
                 speakingStreamIds:(NSArray *)aStreamIds
{
    if (![aConference.callId isEqualToString:self.conference.callId]) {
        return;
    }
}

- (void)streamIdDidUpdate:(EMCallConference*)aConference rtcId:(NSString*)rtcId streamId:(NSString*)streamId
{
    if (![aConference.callId isEqualToString:self.conference.callId]) {
        return;
    }
    NSString* attrKey = [NSString stringWithFormat:@"%@%@",kInviteAttrHead,[EMClient sharedClient].currentUsername ];
    [[[EMClient sharedClient] conferenceManager] deleteAttributeWithKey:attrKey completion:^(EMError *aError) {
        if(aError) {
            NSLog(@"deleteAttributeWithKey error:%@",aError.errorDescription);
        }
    }];
}

// 播放铃声
- (void)playSound
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self.audioPlayer play];
}

// 停止播放铃声
- (void)stopSound
{
    [self.audioPlayer stop];
}

- (void)conferenceAttributeUpdated:(EMCallConference *)aConference attributes:(NSArray <EMConferenceAttribute *>*)attrs
{
    if (![aConference.callId isEqualToString:self.conference.callId]) {
        return;
    }
    for(EMConferenceAttribute * attr in attrs) {
        if(attr.action == EMConferenceAttributeDelete) {
            if([attr.key containsString:kInviteAttrHead]) {
                
                NSString* uId = [attr.key substringFromIndex:kInviteAttrHead.length];
                // 收到自己的邀请属性删除
                if([uId isEqualToString:[EMClient sharedClient].currentUsername]) {
                    if(self.ringTimer) {
                        [self.ringTimer invalidate];
                        self.ringTimer = nil;
                    }
                    [self stopSound];
                    // 检查是否已经发流,忽略，什么都不做
                    if([self.pubId length] > 0) {
                        
                    }else{
                        [self exitNotify:EMCallEndReasonHangup time:[self getConfrTime]];
                        [self hangupWithType:self.callType];
                    }
                }else{
                    self.inviteeCount--;
                    [self.invitees removeObject:uId];
                    NSTimer* timer = [self.inviteTimerDic objectForKey:uId];
                    if(timer) {
                        [timer invalidate];
                        timer = nil;
                        [self.inviteTimerDic removeObjectForKey:uId];
                    }
                    if(self.callType == EaseCallTypeMulti) {
                        if(self.multiVC)
                           [self.multiVC removePlaceHolderForMember:uId];
                    }
                }
                [self checkIfNeedExit];
            }
        }else{
            if([attr.key containsString:kInviteAttrHead]) {
                NSString* uId = [attr.key substringFromIndex:kInviteAttrHead.length];
                if([uId isEqualToString:[EMClient sharedClient].currentUsername]) {
                    // 被邀请人收到自己的邀请会议属性创建，振铃
                    if(self.ringTimer) {
                        [self.ringTimer invalidate];
                        self.ringTimer = nil;
                    }
                    if([self.delegate respondsToSelector:@selector(callDidReceive:inviter:)]){
                        [self.delegate callDidReceive:self.callType inviter:self.callFrom];
                    }
                    // 开始播放铃声
                    [self playSound];
                    if(self.callType != EaseCallTypeMulti) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.singleVC = [[EaseCallSingleViewController alloc] initWithisCaller:NO type:self.callType remoteName:uId];
                            if(self.singleVC) {
                                self.singleVC.modalPresentationStyle = UIModalPresentationFullScreen;
                                UIViewController *rootViewController = [[UIApplication sharedApplication].delegate window].rootViewController;

                                [rootViewController presentViewController:self.singleVC animated:NO completion:nil];
                                
                            }
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(!self.multiVC)
                                self.multiVC = [[EaseCallMultiViewController alloc] init];
                            else
                                return;
                            self.multiVC.inviterId = self.callFrom;
                            for(NSString* memberId in self.unShowPlaces) {
                                [self.multiVC setPlaceHolderUrl:self.config.placeHolderURL member:memberId];
                            }
                            if(self.multiVC) {
                                self.multiVC.modalPresentationStyle = UIModalPresentationFullScreen;
                                UIViewController *rootViewController = [[UIApplication sharedApplication].delegate window].rootViewController;

                                [rootViewController presentViewController:self.multiVC animated:NO completion:nil];
                            }
                        });
                    }
                }else{
                    // 邀请人或第三方监测到邀请会议属性创建，开启邀请超时定时器
                    self.inviteeCount++;
                    if(![self.invitees containsObject:uId])
                        [self.invitees addObject:uId];
                    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:self.config.callTimeOut target:self selector:@selector(_timeoutBeforeInviteeAnswered:) userInfo:uId repeats:NO];
                    [self.inviteTimerDic setObject:timer forKey:uId];
                    if(self.callType == EaseCallTypeMulti) {
                        if(self.multiVC)
                            [self.multiVC setPlaceHolderUrl:self.config.placeHolderURL member:uId];
                        else{
                            [self.unShowPlaces addObject:uId];
                        }
                    }
                }
            }
        }
    }
    if(self.ringTimer) {
        [self.ringTimer invalidate];
        self.ringTimer = nil;
        [self exitNotify:EMCallEndReasonHangup time:[self getConfrTime]];
        [self hangupWithType:self.callType];
    }
}

- (void)checkIfNeedExit
{
    if(self.memberCount + self.inviteeCount == 0) {
        [[[EMClient sharedClient] conferenceManager] leaveConference:self.conference completion:^(EMError *aError) {
            self.conference = nil;
            self.pubId = nil;
        }];
        
        if(self.callType != EaseCallTypeMulti) {
            [self exitNotify:EMCallEndReasonHangup time:self.singleVC.timeLength];
            [self.singleVC dismissViewControllerAnimated:NO completion:nil];
        }else
        {
            if(self.multiVC)
            {
                [self exitNotify:EMCallEndReasonHangup time:self.multiVC.timeLength];
                if(self.multiVC.presentedViewController)
                    [self.multiVC.presentedViewController dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                [self.multiVC dismissViewControllerAnimated:NO completion:^(void) {
                    self.multiVC = nil;
                }];
            }
        }
    }
}

@end
