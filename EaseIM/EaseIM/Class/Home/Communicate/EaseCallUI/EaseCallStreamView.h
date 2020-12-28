//
//  EaseCallStreamView.h
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/11/19.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    StreamStatusNormal = 0,
    StreamStatusConnecting,
    StreamStatusConnected,
    StreamStatusTalking,
} StreamStatus;

@protocol EaseCallStreamViewDelegate;
@interface EaseCallStreamView : UIView

@property (nonatomic, weak) id<EaseCallStreamViewDelegate> delegate;

@property (nonatomic, strong) UIView *displayView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic) StreamStatus status;

@property (nonatomic) BOOL enableVoice;

@property (nonatomic) BOOL enableVideo;

@property (nonatomic, strong) UIImageView *bgView;

@property (nonatomic) BOOL isLockedBgView;

@property (nonatomic, strong) id ext;

@end

@protocol EaseCallStreamViewDelegate <NSObject>

@optional

- (void)streamViewDidTap:(EaseCallStreamView *)aVideoView;

@end
