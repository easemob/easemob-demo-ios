//
//  EaseCallBaseViewController.m
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/11/19.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import "EaseCallBaseViewController.h"
#import "EaseCallManager+Private.h"
#import <Masonry/Masonry.h>
#import "UIImage+Ext.h"

@interface EaseCallBaseViewController ()

@end

@implementation EaseCallBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setubSubViews];
    
    self.speakerButton.selected = YES;
}

- (void)setubSubViews
{
    int size = 60;
    self.hangupButton = [[UIButton alloc] init];
    self.hangupButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.hangupButton setImage:[UIImage imageNamedFromBundle:@"hangup"] forState:UIControlStateNormal];
    [self.hangupButton addTarget:self action:@selector(hangupAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hangupButton];
    [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-60);
        make.left.equalTo(@30);
        make.width.height.equalTo(@60);
    }];
    
    self.answerButton = [[UIButton alloc] init];
    self.answerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.answerButton setImage:[UIImage imageNamedFromBundle:@"answer"] forState:UIControlStateNormal];
    [self.answerButton addTarget:self action:@selector(answerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.answerButton];
    [self.answerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.hangupButton);
        make.right.equalTo(self.view).offset(-40);
        make.width.height.mas_equalTo(60);
    }];
    
    self.switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.switchCameraButton setImage:[UIImage imageNamedFromBundle:@"switchCamera"] forState:UIControlStateNormal];
    [self.switchCameraButton addTarget:self action:@selector(switchCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.switchCameraButton];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.hangupButton);
        make.width.height.mas_equalTo(60);
        make.centerX.equalTo(self.view).with.multipliedBy(1.5);
    }];
    
    self.microphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.microphoneButton setImage:[UIImage imageNamedFromBundle:@"microphone_enable"] forState:UIControlStateNormal];
    [self.microphoneButton setImage:[UIImage imageNamedFromBundle:@"microphone_disable"] forState:UIControlStateSelected];
    [self.microphoneButton addTarget:self action:@selector(muteAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.microphoneButton];
    [self.microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.left.equalTo(self.speakerButton.mas_right).offset(40);
        make.centerX.equalTo(self.view).with.multipliedBy(0.5);
        make.bottom.equalTo(self.hangupButton.mas_top).with.offset(-40);
        make.width.height.equalTo(@(size));
    }];
    self.microphoneButton.selected = YES;
    
    self.speakerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.speakerButton setImage:[UIImage imageNamedFromBundle:@"speaker_disable"] forState:UIControlStateNormal];
    [self.speakerButton setImage:[UIImage imageNamedFromBundle:@"speaker_enable"] forState:UIControlStateSelected];
    [self.speakerButton addTarget:self action:@selector(speakerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.speakerButton];
    [self.speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.microphoneButton);
        //make.left.equalTo(self.switchCameraButton.mas_right).offset(40);
        make.centerX.equalTo(self.view);
        make.width.height.equalTo(@(size));
    }];
    
    

    self.enableCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.enableCameraButton setImage:[UIImage imageNamedFromBundle:@"video_disable"] forState:UIControlStateNormal];
    [self.enableCameraButton setImage:[UIImage imageNamedFromBundle:@"video_enable"] forState:UIControlStateSelected];
    [self.enableCameraButton addTarget:self action:@selector(enableVideoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.enableCameraButton];
    [self.enableCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.left.equalTo(self.microphoneButton.mas_right).offset(40);
        make.centerX.equalTo(self.view).with.multipliedBy(1.5);
        make.bottom.equalTo(self.microphoneButton);
        make.width.height.equalTo(@(size));
    }];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError* error = nil;
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if(error != nil)
        return;
    [audioSession setActive:YES error:&error];
    if(error != nil)
        return;
    [self.enableCameraButton setEnabled:NO];
    [self.switchCameraButton setEnabled:NO];
    [self.microphoneButton setEnabled:NO];
    _timeLabel = nil;
    
    self.hangupLabel = [[UILabel alloc] init];
    self.hangupLabel.font = [UIFont systemFontOfSize:11];
    self.hangupLabel.textColor = [UIColor whiteColor];
    self.hangupLabel.textAlignment = NSTextAlignmentCenter;
    self.hangupLabel.text = @"挂断";
    [self.view addSubview:self.hangupLabel];
    [self.hangupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hangupButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.hangupButton);
    }];
    
    self.acceptLabel = [[UILabel alloc] init];
    self.acceptLabel.font = [UIFont systemFontOfSize:11];
    self.acceptLabel.textColor = [UIColor whiteColor];
    self.acceptLabel.textAlignment = NSTextAlignmentCenter;
    self.acceptLabel.text = @"接听";
    [self.view addSubview:self.acceptLabel];
    [self.acceptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.answerButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.answerButton);
    }];
    
    self.microphoneLabel = [[UILabel alloc] init];
    self.microphoneLabel.font = [UIFont systemFontOfSize:11];
    self.microphoneLabel.textColor = [UIColor whiteColor];
    self.microphoneLabel.textAlignment = NSTextAlignmentCenter;
    self.microphoneLabel.text = @"静音";
    [self.view addSubview:self.microphoneLabel];
    [self.microphoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.microphoneButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.microphoneButton);
    }];
    
    self.speakerLabel = [[UILabel alloc] init];
    self.speakerLabel.font = [UIFont systemFontOfSize:11];
    self.speakerLabel.textColor = [UIColor whiteColor];
    self.speakerLabel.textAlignment = NSTextAlignmentCenter;
    self.speakerLabel.text = @"免提";
    [self.view addSubview:self.speakerLabel];
    [self.speakerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.speakerButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.speakerButton);
    }];
    
    self.enableCameraLabel = [[UILabel alloc] init];
    self.enableCameraLabel.font = [UIFont systemFontOfSize:11];
    self.enableCameraLabel.textColor = [UIColor whiteColor];
    self.enableCameraLabel.textAlignment = NSTextAlignmentCenter;
    self.enableCameraLabel.text = @"摄像头";
    [self.view addSubview:self.enableCameraLabel];
    [self.enableCameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.enableCameraButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.enableCameraButton);
    }];
    
    self.switchCameraLabel = [[UILabel alloc] init];
    self.switchCameraLabel.font = [UIFont systemFontOfSize:11];
    self.switchCameraLabel.textColor = [UIColor whiteColor];
    self.switchCameraLabel.textAlignment = NSTextAlignmentCenter;
    self.switchCameraLabel.text = @"切换摄像头";
    [self.view addSubview:self.switchCameraLabel];
    [self.switchCameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.switchCameraButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.switchCameraButton);
    }];
}

- (void)answerAction
{
}

- (void)hangupAction
{
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
}

- (void)switchCameraAction
{
    self.switchCameraButton.selected = !self.switchCameraButton.isSelected;
    [[EaseCallManager sharedManager] switchCameraAction];
}

- (void)speakerAction
{
    self.speakerButton.selected = !self.speakerButton.isSelected;
    if(self.speakerButton.isSelected){
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError* error = nil;
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        if(error != nil)
            return;
        [audioSession setActive:YES error:&error];
        if(error != nil)
            return;
    }else{
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError* error = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions: AVAudioSessionCategoryOptionAllowBluetooth error:&error];
        if(error != nil)
            return;
        [audioSession setActive:YES error:&error];
        if(error != nil)
            return;
    }
}

- (void)muteAction
{
    self.microphoneButton.selected = !self.microphoneButton.isSelected;
    [[EaseCallManager sharedManager] muteAction:!self.microphoneButton.selected];
}

- (void)enableVideoAction
{
    self.enableCameraButton.selected = !self.enableCameraButton.isSelected;
    [[EaseCallManager sharedManager] enableVideoAction:self.enableCameraButton.selected];
}


#pragma mark - timer

- (void)startTimer
{
    if(!_timeLabel) {
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [UIFont systemFontOfSize:25];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.text = @"00:00";
        [self.view addSubview:self.timeLabel];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.hangupButton.mas_top).with.offset(-20);
            make.centerX.equalTo(self.view);
        }];
        _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
    }
    
}

- (void)timeTimerAction:(id)sender
{
    _timeLength += 1;
    int m = (_timeLength) / 60;
    int s = _timeLength - m * 60;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", m, s];
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
