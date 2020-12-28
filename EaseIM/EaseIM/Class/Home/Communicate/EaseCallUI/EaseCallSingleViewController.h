//
//  EaseCallSingleViewController.h
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/11/19.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import "EaseCallBaseViewController.h"
#import "EaseCallStreamView.h"
#import "EaseCallManager+Private.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseCallSingleViewController : EaseCallBaseViewController
@property (nonatomic,strong) EaseCallStreamView* remoteView;
@property (nonatomic,strong) EaseCallStreamView* localView;
@property (nonatomic) BOOL isCaller;
@property (nonatomic,strong) UILabel* remoteNameLable;
@property (nonatomic,strong) UIImageView* remoteHeadView;
@property (nonatomic,strong) UIButton* switchToVoice;
@property (nonatomic,strong) UILabel* switchToVoiceLable;

- (instancetype)initWithisCaller:(BOOL)aIsCaller type:(EaseCallType)aType  remoteName:(NSString*)aRemoteName;
- (void)setRemoteMute:(BOOL)aMuted;
- (void)setRemoteEnableVideo:(BOOL)aMuted;
- (void)setLocalDisplayView:(UIView*)aDisplayView enableVideo:(BOOL)aEnableVideo;
- (void)setRemoteDisplayView:(UIView*)aDisplayView enableVideo:(BOOL)aEnableVideo;
- (void)updateToVoice;
- (void)showTip:(BOOL)aEnableVoice;
@end

NS_ASSUME_NONNULL_END
