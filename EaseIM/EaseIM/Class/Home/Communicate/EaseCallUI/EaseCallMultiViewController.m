//
//  EaseCallMultiViewController.m
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/11/19.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import "EaseCallMultiViewController.h"
#import "EaseCallStreamView.h"
#import "EaseCallManager+Private.h"
#import "EaseCallPlaceholderView.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+Ext.h"

@interface EaseCallMultiViewController ()
@property (nonatomic) NSMutableDictionary* streamViewsDic;
@property (nonatomic) NSMutableDictionary* placeHolderViewsDic;
@property (nonatomic) EaseCallStreamView* localView;
@property (nonatomic) UIButton* inviteButton;
@property (nonatomic) UILabel* statusLable;
@property (nonatomic) NSMutableDictionary* streamsEnableVideo;
@property (nonatomic) NSMutableDictionary* streamsEnableVoice;
@end

@implementation EaseCallMultiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubViews];
    [self updateViewPos];
}

- (void)setupSubViews
{
    self.view.backgroundColor = [UIColor grayColor];
    self.confrNameLable = [[UILabel alloc] init];
    self.confrNameLable.backgroundColor = [UIColor clearColor];
    self.confrNameLable.font = [UIFont systemFontOfSize:28];
    self.confrNameLable.textColor = [UIColor whiteColor];
    self.confrNameLable.textAlignment = NSTextAlignmentRight;
    NSString* title = [[EaseCallManager sharedManager] getEaseCallConfig].title;
    self.confrNameLable.text = title;
    [self.timeLabel setHidden:YES];
    [self.view addSubview:self.confrNameLable];
    [self.confrNameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@40);
        make.left.equalTo(@10);
    }];
    self.inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.inviteButton setImage:[UIImage imageNamedFromBundle:@"invite"] forState:UIControlStateNormal];
    [self.inviteButton addTarget:self action:@selector(inviteAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.inviteButton];
    [self.inviteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@40);
        make.right.equalTo(self.view);
        make.width.height.equalTo(@50);
    }];
    [self.view bringSubviewToFront:self.inviteButton];
    [self.inviteButton setHidden:YES];
    
    if(self.localView) {
        self.answerButton.hidden = YES;
        self.acceptLabel.hidden = YES;
        [self.hangupButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
        }];
    }else{
        NSURL* remoteUrl = [self getHeadImageUrlFromUid:self.inviterId];
        self.remoteHeadView = [[UIImageView alloc] init];
        [self.view addSubview:self.remoteHeadView];
        [self.remoteHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@80);
            make.centerX.equalTo(self.view);
            make.top.equalTo(@100);
        }];
        [self.remoteHeadView sd_setImageWithURL:remoteUrl];
        self.remoteNameLable = [[UILabel alloc] init];
        self.remoteNameLable.backgroundColor = [UIColor clearColor];
        self.remoteNameLable.font = [UIFont systemFontOfSize:19];
        self.remoteNameLable.textColor = [UIColor whiteColor];
        self.remoteNameLable.textAlignment = NSTextAlignmentRight;
        self.remoteNameLable.text = [[EaseCallManager sharedManager] getNickNameFromUID:self.inviterId];
        [self.timeLabel setHidden:YES];
        [self.view addSubview:self.remoteNameLable];
        [self.remoteNameLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.remoteHeadView.mas_bottom).offset(10);
            make.centerX.equalTo(self.view);
        }];
        self.statusLable = [[UILabel alloc] init];
        self.statusLable.backgroundColor = [UIColor clearColor];
        self.statusLable.font = [UIFont systemFontOfSize:15];
        self.statusLable.textColor = [UIColor whiteColor];
        self.statusLable.textAlignment = NSTextAlignmentRight;
        self.statusLable.text = @"邀请你进行音视频会话";
        [self.view addSubview:self.statusLable];
        [self.statusLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.remoteNameLable.mas_bottom);
            make.centerX.equalTo(self.view);
        }];
    }
    
}

- (NSMutableDictionary*)streamViewsDic
{
    if(!_streamViewsDic) {
        _streamViewsDic = [NSMutableDictionary dictionary];
    }
    return _streamViewsDic;
}

- (NSMutableDictionary*)placeHolderViewsDic
{
    if(!_placeHolderViewsDic) {
        _placeHolderViewsDic = [NSMutableDictionary dictionary];
    }
    return _placeHolderViewsDic;
}

- (NSMutableDictionary*)streamsEnableVideo
{
    if(!_streamsEnableVideo) {
        _streamsEnableVideo = [NSMutableDictionary dictionary];
    }
    return _streamsEnableVideo;
}

- (NSMutableDictionary*)streamsEnableVoice
{
    if(!_streamsEnableVoice) {
        _streamsEnableVoice = [NSMutableDictionary dictionary];
    }
    return _streamsEnableVoice;
}

- (void)addRemoteView:(EMCallRemoteView*)remoteView streamId:(NSString*)streamId  member:(NSString*)uId enableVideo:(BOOL)aEnableVideo
{
    EaseCallStreamView* view = [[EaseCallStreamView alloc] init];
    view.displayView = remoteView;
    view.enableVideo = aEnableVideo;
    [view addSubview:remoteView];
    [self.view addSubview:view];
    [remoteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
    }];
    [self.view sendSubviewToBack:view];
    [self.streamViewsDic setObject:view forKey:streamId];
    if([uId length] > 0)
       [self removePlaceHolderForMember:uId];
    [view.bgView sd_setImageWithURL:[self getHeadImageUrlFromUid:uId]];
    view.nameLabel.text = [[EaseCallManager sharedManager] getNickNameFromUID:uId];
    [self startTimer];
    [self updateViewPos];
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

- (void)removeRemoteViewForStreamId:(NSString*)streamId
{
    EaseCallStreamView* view = [self.streamViewsDic objectForKey:streamId];
    if(view) {
        [view removeFromSuperview];
        [self.streamViewsDic removeObjectForKey:streamId];
    }
    [self updateViewPos];
}
- (void)setRemoteMute:(BOOL)aMuted streamId:(NSString*)streamId
{
    EaseCallStreamView* view = [self.streamViewsDic objectForKey:streamId];
    if(view) {
        NSNumber* enableVoice = [self.streamsEnableVoice objectForKey:streamId];
        if(enableVoice) {
            view.enableVoice = [enableVoice boolValue];
            [self.streamsEnableVoice removeObjectForKey:streamId];
        }else
            view.enableVoice = !aMuted;
    }else{
        [self.streamsEnableVoice setObject:[NSNumber numberWithBool:aMuted] forKey:streamId];
    }
}
- (void)setRemoteEnableVideo:(BOOL)aEnabled streamId:(NSString*)streamId
{
    EaseCallStreamView* view = [self.streamViewsDic objectForKey:streamId];
    if(view) {
        NSNumber* enableVideo = [self.streamsEnableVideo objectForKey:streamId];
        if(enableVideo) {
            view.enableVideo = [enableVideo boolValue];
            [self.streamsEnableVideo removeObjectForKey:streamId];
        }else
            view.enableVideo = aEnabled;
    }else{
        [self.streamsEnableVideo setObject:[NSNumber numberWithBool:aEnabled] forKey:streamId];
    }
}

- (void)setLocalVideoView:(EMCallLocalView*)aDisplayView  enableVideo:(BOOL)aEnableVideo
{
    self.localView = [[EaseCallStreamView alloc] init];
    self.localView.displayView = aDisplayView;
    self.localView.enableVideo = aEnableVideo;
    [self.localView addSubview:aDisplayView];
    [aDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.localView);
    }];
    [self.view addSubview:self.localView];
    [self.localView.bgView sd_setImageWithURL:[self getHeadImageUrlFromUid:[EMClient sharedClient].currentUsername]];
    self.localView.nameLabel.text = [[EaseCallManager sharedManager] getNickNameFromUID:[EMClient sharedClient].currentUsername];
    //[self.view sendSubviewToBack:self.localView];
    [self updateViewPos];
    self.answerButton.hidden = YES;
    self.acceptLabel.hidden = YES;
    [self.hangupButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
    }];
    [self.inviteButton setHidden:NO];
    
    [self.enableCameraButton setEnabled:YES];
    [self.switchCameraButton setEnabled:YES];
    [self.microphoneButton setEnabled:YES];
    self.enableCameraButton.selected = NO;
    [self.remoteNameLable removeFromSuperview];
    [self.statusLable removeFromSuperview];
    [self.remoteHeadView removeFromSuperview];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError* error = nil;
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if(error != nil)
        return;
    [audioSession setActive:YES error:&error];
    if(error != nil)
        return;
}

- (void)updateViewPos
{
    unsigned long count = self.streamViewsDic.count + self.placeHolderViewsDic.count;
    if(self.localView.displayView)
        count++;
    int index = 0;
    int top = 80;
    int left = 10;
    int right = 10;
    int colSize = 1;
    int colomns = count>6?3:2;
    int cellwidth = (self.view.frame.size.width - left - right - (colomns - 1)*colSize)/colomns ;
    int cellHeight = cellwidth;
    if(self.localView.displayView) {
        self.localView.frame = CGRectMake(left + index%colomns * (cellwidth + colSize), top + index/colomns * (cellHeight + colSize), cellwidth, cellHeight);
        index++;
        self.microphoneButton.hidden = NO;
        self.microphoneLabel.hidden = NO;
        self.enableCameraButton.hidden = NO;
        self.enableCameraLabel.hidden = NO;
        self.speakerButton.hidden = NO;
        self.speakerLabel.hidden = NO;
        self.switchCameraButton.hidden = NO;
        self.switchCameraLabel.hidden = NO;
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.inviteButton);
            make.width.equalTo(@100);
        }];
        NSArray* views = [self.streamViewsDic allValues];
        for(EaseCallStreamView* view in views) {
            view.frame = CGRectMake(left + index%colomns * (cellwidth + colSize), top + index/colomns * (cellHeight + colSize), cellwidth, cellHeight);
            index++;
        }
        
        NSArray* placeViews = [self.placeHolderViewsDic allValues];
        for(EaseCallPlaceholderView* placeView in placeViews) {
            placeView.frame = CGRectMake(left + index%colomns * (cellwidth + colSize), top + index/colomns * (cellHeight + colSize), cellwidth, cellHeight);
            index++;
        }
    }else{
        self.microphoneButton.hidden = YES;
        self.microphoneLabel.hidden = YES;
        self.enableCameraButton.hidden = YES;
        self.enableCameraLabel.hidden = YES;
        self.speakerButton.hidden = YES;
        self.speakerLabel.hidden = YES;
        self.switchCameraButton.hidden = YES;
        self.switchCameraLabel.hidden = YES;
    }
}

- (void)inviteAction
{
    [[EaseCallManager sharedManager] inviteMemberAction];
}

- (void)answerAction
{
    self.answerButton.hidden = YES;
    [self.hangupButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
    }];
    [[EaseCallManager sharedManager] acceptWithType:EaseCallTypeMulti];
}

- (void)hangupAction
{
    [super hangupAction];
    [[EaseCallManager sharedManager] hangupWithType:EaseCallTypeMulti];
}

- (void)muteAction
{
    [super muteAction];
    self.localView.enableVoice = self.microphoneButton.isSelected;
}

- (void)setPlaceHolderUrl:(NSURL*)url member:(NSString*)uId
{
    EaseCallPlaceholderView* view = [self.placeHolderViewsDic objectForKey:uId];
    if(view)
        return;
    EaseCallPlaceholderView* placeHolderView = [[EaseCallPlaceholderView alloc] init];
    [self.view addSubview:placeHolderView];
    [placeHolderView.nameLabel setText:[[EaseCallManager sharedManager] getNickNameFromUID:uId]];
//    NSData* data = [NSData dataWithContentsOfURL:url ];
//    [placeHolderView.placeHolder setImage:[UIImage imageWithData:data]];
    [placeHolderView.placeHolder sd_setImageWithURL:url];
    [self.placeHolderViewsDic setObject:placeHolderView forKey:uId];
    [self updateViewPos];
}

- (void)removePlaceHolderForMember:(NSString*)uId
{
    EaseCallPlaceholderView* view = [self.placeHolderViewsDic objectForKey:uId];
    if(view)
       [view removeFromSuperview];
    [self.placeHolderViewsDic removeObjectForKey:uId];
    [self updateViewPos];
}

- (void)enableVideoAction
{
    [super enableVideoAction];
    self.localView.enableVideo = self.enableCameraButton.isSelected;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
