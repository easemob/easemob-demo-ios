//
//  EaseCallMultiViewController.h
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/11/19.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import "EaseCallBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseCallMultiViewController : EaseCallBaseViewController
- (void)addRemoteView:(EMCallRemoteView*)remoteView streamId:(NSString*)streamId member:(NSString*)uId enableVideo:(BOOL)aEnableVideo;
- (void)removeRemoteViewForStreamId:(NSString*)streamId;
- (void)setRemoteMute:(BOOL)aMuted streamId:(NSString*)streamId;
- (void)setRemoteEnableVideo:(BOOL)aMuted streamId:(NSString*)streamId;
- (void)setLocalVideoView:(EMCallLocalView*)localView enableVideo:(BOOL)aEnableVideo;
- (void)setPlaceHolderUrl:(NSURL*)url member:(NSString*)uId;
- (void)removePlaceHolderForMember:(NSString*)uId;
@property (nonatomic,strong) UILabel* confrNameLable;
@property (nonatomic,strong) UILabel* remoteNameLable;
@property (nonatomic,strong) NSString* inviterId;
@property (nonatomic,strong) UIImageView* remoteHeadView;
@end

NS_ASSUME_NONNULL_END
