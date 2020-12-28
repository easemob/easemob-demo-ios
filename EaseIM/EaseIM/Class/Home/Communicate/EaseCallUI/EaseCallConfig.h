//
//  EaseCallConfig.h
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/12/9.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface EaseCallUser : NSObject
@property (nonatomic)  NSString* _Nonnull  uId;
@property (nonatomic)  NSString* _Nullable  nickName;
@property (nonatomic)  NSURL* _Nullable  headImage;
@end
// 增加铃声、标题文本、环信ID与昵称的映射
@interface EaseCallConfig : NSObject
// 呼叫超时时间
@property (nonatomic) UInt32 callTimeOut;
// 占位符图片地址
@property (nonatomic) NSURL* placeHolderURL;
// 用户信息字典,key为环信ID，value为EaseCallUser
@property (nonatomic) NSMutableDictionary* users;
// 会议标题
@property (nonatomic) NSString* _Nullable title;
// 振铃文件
@property (nonatomic) NSURL* ringFileUrl;
// 语音通话可以转视频通话
@property (nonatomic) BOOL canSwitchVoiceToVideo;
@end

NS_ASSUME_NONNULL_END
