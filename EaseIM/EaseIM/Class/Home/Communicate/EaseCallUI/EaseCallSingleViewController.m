//
//  EaseCallSingleViewController.m
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/11/19.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import "EaseCallSingleViewController.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+Ext.h"

@interface EaseCallSingleViewController ()<EaseCallStreamViewDelegate>
@property (nonatomic) NSString* remoteUid;
@property (nonatomic) UILabel* statusLable;
@property (nonatomic) EaseCallType type;
@property (nonatomic) UIView* viewRoundHead;
@property (nonatomic) UILabel * tipLabel;
@end

@implementation EaseCallSingleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _remoteView = nil;
    self.view.backgroundColor = [UIColor grayColor];
    NSURL* remoteUrl = [self getHeadImageUrlFromUid:self.remoteUid];
    self.remoteHeadView = [[UIImageView alloc] init];
    [self.view addSubview:self.remoteHeadView];
    [self.remoteHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@80);
        make.centerX.equalTo(self.view);
        make.top.equalTo(@100);
    }];
    [self.remoteHeadView sd_setImageWithURL:remoteUrl];
    [self drawViewRoundHead];
    self.remoteNameLable = [[UILabel alloc] init];
    self.remoteNameLable.backgroundColor = [UIColor clearColor];
    self.remoteNameLable.font = [UIFont systemFontOfSize:19];
    self.remoteNameLable.textColor = [UIColor whiteColor];
    self.remoteNameLable.textAlignment = NSTextAlignmentRight;
    self.remoteNameLable.text = [[EaseCallManager sharedManager] getNickNameFromUID:self.remoteUid];
    [self.timeLabel setHidden:YES];
    [self.view addSubview:self.remoteNameLable];
    [self.remoteNameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.viewRoundHead.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
    }];
    self.statusLable = [[UILabel alloc] init];
    self.statusLable.backgroundColor = [UIColor clearColor];
    self.statusLable.font = [UIFont systemFontOfSize:15];
    self.statusLable.textColor = [UIColor whiteColor];
    self.statusLable.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.statusLable];
    [self.statusLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remoteNameLable.mas_bottom).with.offset(20);
        make.centerX.equalTo(self.view);
    }];
    
    self.switchToVoiceLable = [[UILabel alloc] init];
    self.switchToVoiceLable.backgroundColor = [UIColor clearColor];
    self.switchToVoiceLable.font = [UIFont systemFontOfSize:11];
    self.switchToVoiceLable.textColor = [UIColor whiteColor];
    self.switchToVoiceLable.textAlignment = NSTextAlignmentCenter;
    self.switchToVoiceLable.text = @"转音频";
    [self.view addSubview:self.switchToVoiceLable];
    if(self.isCaller) {
        [self.switchToVoiceLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.hangupButton.mas_top).with.offset(-5);
            make.centerX.equalTo(self.hangupButton);
        }];
    }else{
        [self.switchToVoiceLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.answerButton.mas_top).with.offset(-5);
            make.centerX.equalTo(self.answerButton);
        }];
    }
    
    
    self.switchToVoice = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.switchToVoice setTintColor:[UIColor whiteColor]];
    [self.switchToVoice setImage:[UIImage imageNamedFromBundle:@"Audio-mute"] forState:UIControlStateNormal];
    [self.switchToVoice addTarget:self action:@selector(switchToVoiceAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.switchToVoice];
    [self.switchToVoice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@40);
            make.centerX.equalTo(self.switchToVoiceLable);
        make.bottom.equalTo(self.switchToVoiceLable.mas_top).with.offset(-5);
    }];
    
    if(self.isCaller) {
        self.statusLable.text = @"正在等待对方接受邀请";
        self.answerButton.hidden = YES;
        self.acceptLabel.hidden = YES;
    }else
        self.statusLable.text = @"邀请你进行音视频通话";
    [self updatePos];
    
}

- (void)drawViewRoundHead
{
    self.viewRoundHead = [[UIView alloc] init];
    self.viewRoundHead.layer.backgroundColor = [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0].CGColor;
    self.viewRoundHead.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.02].CGColor;
    self.viewRoundHead.layer.shadowOffset = CGSizeMake(0,0);
    self.viewRoundHead.layer.shadowOpacity = 1;
    self.viewRoundHead.layer.shadowRadius = 15;
    self.viewRoundHead.layer.cornerRadius = 119;
    [self.view addSubview:self.viewRoundHead];
    [self.viewRoundHead mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.remoteHeadView);
            make.width.height.equalTo(@238);
    }];
    
    UIView* view2 = [[UIView alloc] init];
    view2.layer.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0].CGColor;
    view2.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.04].CGColor;
    view2.layer.shadowOffset = CGSizeMake(0,0);
    view2.layer.shadowOpacity = 1;
    view2.layer.shadowRadius = 12;
    view2.layer.cornerRadius = 90;
    [self.viewRoundHead addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.viewRoundHead);
            make.width.height.equalTo(@179);
    }];
    
    UIView* view3 = [[UIView alloc] init];
    view3.layer.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0].CGColor;
    view3.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.04].CGColor;
    view3.layer.shadowOffset = CGSizeMake(0,0);
    view3.layer.shadowOpacity = 1;
    view3.layer.shadowRadius = 12;
    view3.layer.cornerRadius = 65;
    [view2 addSubview:view3];
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.viewRoundHead);
            make.width.height.equalTo(@129);
    }];
    
    [self.view sendSubviewToBack:self.viewRoundHead];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 325, 330, 30)];
    _tipLabel.backgroundColor = [UIColor blackColor];
    _tipLabel.layer.cornerRadius = 5;
    _tipLabel.layer.masksToBounds = YES;
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.textColor = [UIColor whiteColor];
    _tipLabel.alpha = 0.0;
    [self.view addSubview:_tipLabel];
}

- (void)switchToVoiceAction
{
    [self updateToVoice];
    if(!self.remoteView) {
        [self answerAction];
    }
}

- (void)updateToVoice
{
    if(self.type == EaseCallType1v1Audio)
        return;
    [[EaseCallManager sharedManager] enableVideoAction:NO];
    self.type = EaseCallType1v1Audio;
    [self updatePos];
}

- (nonnull instancetype)initWithisCaller:(BOOL)aIsCaller type:(EaseCallType)aType remoteName:(NSString*)aRemoteName {
    self = [super init];
    if(self) {
        self.isCaller = aIsCaller;
        self.remoteUid = aRemoteName;
        self.type = aType;
    }
    return  self;
}

- (void)updatePos
{
    if(self.type == EaseCallType1v1Audio) {
        // 音频
        [self.remoteHeadView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@80);
            make.centerX.equalTo(self.view);
            make.top.equalTo(@230);
        }];
        self.switchToVoice.hidden = YES;
        self.switchToVoiceLable.hidden = YES;
        self.enableCameraButton.hidden = YES;
        self.enableCameraLabel.hidden = YES;
        self.switchCameraButton.hidden = YES;
        self.switchCameraLabel.hidden = YES;
        self.localView.hidden = YES;
        self.remoteView.hidden = YES;
        self.remoteNameLable.hidden = NO;
        self.viewRoundHead.hidden = NO;
        [self.answerButton setImage:[UIImage imageNamedFromBundle:@"answer"] forState:UIControlStateNormal];
        if(_remoteView) {
            // 接通
            self.microphoneButton.hidden = NO;
            self.microphoneLabel.hidden = NO;
            self.speakerButton.hidden = NO;
            self.speakerLabel.hidden = NO;
            self.microphoneButton.enabled = YES;
            self.speakerButton.enabled = YES;
            self.answerButton.hidden = YES;
            self.acceptLabel.hidden = YES;
            self.remoteHeadView.hidden = NO;
            [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.width.height.equalTo(@60);
                make.bottom.equalTo(self.view).with.offset(-40);
            }];
            [self.microphoneButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.bottom.equalTo(self.hangupButton);
//                    make.width.height.equalTo(self.hangupButton);
                make.bottom.equalTo(self.view).with.offset(-40);
                make.left.equalTo(@40);
            }];
            [self.speakerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.bottom.equalTo(self.hangupButton);
//                    make.width.height.equalTo(self.hangupButton);
                make.bottom.equalTo(self.view).with.offset(-40);
                make.right.equalTo(self.view).with.offset(-40);
            }];
        }else{
            // 未接通
            if(_isCaller) {
                // 发起方
                self.microphoneButton.hidden = NO;
                self.microphoneLabel.hidden = NO;
                self.speakerButton.hidden = NO;
                self.speakerLabel.hidden = NO;
                self.microphoneButton.enabled = NO;
                self.speakerButton.enabled = NO;
                self.answerButton.hidden = YES;
                self.acceptLabel.hidden = YES;
                [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.view);
                    make.width.height.equalTo(@60);
                    make.bottom.equalTo(self.view).with.offset(-40);
                }];
                [self.microphoneButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.bottom.equalTo(self.hangupButton);
//                    make.width.height.equalTo(self.hangupButton);
                    make.bottom.equalTo(self.view).with.offset(-40);
                    make.left.equalTo(@40);
                }];
                [self.speakerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.bottom.equalTo(self.hangupButton);
//                    make.width.height.equalTo(self.hangupButton);
                    make.bottom.equalTo(self.view).with.offset(-40);
                    make.right.equalTo(self.view).with.offset(-40);
                }];
                
            }else{
                self.microphoneButton.hidden = YES;
                self.microphoneLabel.hidden = YES;
                self.speakerButton.hidden = YES;
                self.speakerLabel.hidden = YES;
                self.answerButton.hidden = NO;
                self.acceptLabel.hidden = NO;
                [self.hangupButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(@40);
                }];
            }
        }
    }else{
        //视频
        self.enableCameraButton.hidden = YES;
        self.enableCameraLabel.hidden = YES;
        self.microphoneButton.hidden = YES;
        self.microphoneLabel.hidden = YES;
        self.speakerButton.hidden = YES;
        self.speakerLabel.hidden = YES;
        self.localView.hidden = NO;
        self.remoteView.hidden = NO;
        self.viewRoundHead.hidden = YES;
        [self.remoteHeadView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@80);
            make.centerX.equalTo(self.view);
            make.top.equalTo(@100);
        }];
        [self.answerButton setImage:[UIImage imageNamedFromBundle:@"camera_answer"] forState:UIControlStateNormal];
        if(_remoteView) {
            // 接通
            self.remoteHeadView.hidden = YES;
            self.remoteNameLable.hidden = YES;
            self.switchCameraButton.hidden = NO;
            self.switchCameraLabel.hidden = NO;
            self.answerButton.hidden = YES;
            self.acceptLabel.hidden = YES;
            self.switchToVoice.hidden = NO;
            self.switchToVoiceLable.hidden = NO;
            [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.width.height.equalTo(@60);
                make.bottom.equalTo(self.view).with.offset(-40);
            }];
            [self.switchToVoiceLable mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@60);
                make.bottom.equalTo(self.view).with.offset(-40);
            }];
            [self.switchToVoice mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.switchToVoiceLable);
                make.bottom.equalTo(self.switchToVoiceLable.mas_top).with.offset(-5);
                make.width.height.equalTo(@40);
            }];
            [self.switchCameraButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.bottom.equalTo(self.view).with.offset(-40);
                            make.right.equalTo(self.view).with.offset(-40);
            }];
        }else{
            // 未接通
            if(_isCaller) {
                // 发起方
                self.switchCameraButton.hidden = YES;
                self.switchCameraLabel.hidden = YES;
                self.answerButton.hidden = YES;
                self.acceptLabel.hidden = YES;
                self.switchToVoice.hidden = NO;
                self.switchToVoiceLable.hidden = NO;
                [self.hangupButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.view);
                }];
            }else{
                // 接听方
                self.switchCameraButton.hidden = YES;
                self.switchCameraLabel.hidden = YES;
                self.answerButton.hidden = NO;
                self.acceptLabel.hidden = NO;
                [self.hangupButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(@40);
                }];
            }
        }
    }
}

- (void)setLocalView:(EaseCallStreamView *)localView
{
    _localView = localView;
    [self.view addSubview:_localView];
    [self.view sendSubviewToBack:_localView];
    [self.localView.bgView sd_setImageWithURL:[self getHeadImageUrlFromUid:[EMClient sharedClient].currentUsername]];
    //self.localView.nameLabel.text = [[EaseCallManager sharedManager] getNickNameFromUID:[EMClient sharedClient].currentUsername];
    localView.delegate = self;
    [_localView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.enableCameraButton setEnabled:YES];
    [self.switchCameraButton setEnabled:YES];
    [self.microphoneButton setEnabled:YES];
    if(self.type == EaseCallType1v1Video)
    {
        self.enableCameraButton.selected = YES;
        self.localView.enableVideo = YES;
    }else
    {
        self.localView.enableVideo = NO;
        [self.localView setHidden:YES];
    }
}

- (void)setRemoteView:(EaseCallStreamView *)remoteView
{
    _remoteView = remoteView;
    remoteView.delegate = self;
    [self.view addSubview:_remoteView];
    [_remoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@100);
        make.right.equalTo(self.view).with.offset(-40);
        make.top.equalTo(self.view).with.offset(70);
    }];
    [self startTimer];
    //[self.remoteNameLable setHidden:YES];
    [self.statusLable setHidden:YES];
    [self updatePos];
}

- (void)answerAction
{
    self.answerButton.hidden = YES;
    self.acceptLabel.hidden = YES;
    [self.hangupButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
    }];
    [[EaseCallManager sharedManager] acceptWithType:self.type];
}

- (void)hangupAction
{
    [super hangupAction];
    [[EaseCallManager sharedManager] hangupWithType:self.type];
}

- (void)muteAction
{
    [super muteAction];
    self.localView.enableVoice = self.microphoneButton.isSelected;
}

- (void)streamViewDidTap:(EaseCallStreamView *)aVideoView
{
    if(aVideoView.frame.size.width == 80) {
        [self.view sendSubviewToBack:aVideoView];
        EaseCallStreamView *otherView = aVideoView == self.localView?self.remoteView:self.localView;
        [otherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@80);
            make.height.equalTo(@100);
            make.right.equalTo(self.view).with.offset(-40);
            make.top.equalTo(self.view).with.offset(70);
        }];
        [aVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
    }
}

- (void)setLocalDisplayView:(UIView*)aDisplayView enableVideo:(BOOL)aEnableVideo
{
    if(self.localView)
    {
        self.localView.displayView = aDisplayView;
        self.localView.delegate = self;
        [self.localView addSubview:aDisplayView];
        self.localView.enableVideo = aEnableVideo;
        [aDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.localView);
        }];
        if(!aEnableVideo) {
            self.enableCameraButton.selected = NO;
        }
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError* error = nil;
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if(error != nil)
        return;
    [audioSession setActive:YES error:&error];
    if(error != nil)
        return;
}
- (void)setRemoteDisplayView:(UIView*)aDisplayView enableVideo:(BOOL)aEnableVideo
{
    if(self.remoteView)
    {
        self.remoteView.displayView = aDisplayView;
        self.remoteView.delegate = self;
        [self.remoteView addSubview:aDisplayView];
        self.remoteView.enableVideo = aEnableVideo;
        //self.remoteView.nameLabel.text = [[EaseCallManager sharedManager] getNickNameFromUID:self.remoteUid];
        [self.remoteView.bgView sd_setImageWithURL:[self getHeadImageUrlFromUid:self.remoteUid]];
        [aDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.remoteView);
        }];
        if(!aEnableVideo && self.type == EaseCallType1v1Video) {
            [self switchToVoiceAction];
        }
        if(self.type == EaseCallType1v1Video) {
            [self streamViewDidTap:self.remoteView];
        }
    }
    
    [self updatePos];
}

- (NSURL*)getHeadImageUrlFromUid:(NSString*)uId
{
    EaseCallConfig* config = [[EaseCallManager sharedManager] getEaseCallConfig];
    if(config)
    {
        if(config.users) {
            EaseCallUser* user = [config.users objectForKey:uId];
            
            if(user && user.headImage) {
                NSString* str = [user.headImage absoluteString];
                if(str && [str length] > 0)
                    return user.headImage;
            }
        }else{
            return config.placeHolderURL;
        }
        
    }
    NSString* path = [NSString stringWithFormat:@"EaseCall.bundle/icon"];
    NSURL* url = [[NSBundle mainBundle] URLForResource:path withExtension:@"png"];
    return url;
}

- (void)enableVideoAction
{
    [super enableVideoAction];
    self.localView.enableVideo = self.enableCameraButton.isSelected;
}

- (void)showTip:(BOOL)aEnableVoice
{
    NSString* msg = @"";
    if(aEnableVoice)
        msg = @"对方打开了音频";
    else
        msg = @"对方关闭了音频";
    _tipLabel.alpha = 1.0;
    self.tipLabel.text = msg;
    [UIView animateWithDuration:3 animations:^{
            self.tipLabel.alpha = 0.0;
        }];
}

@end
