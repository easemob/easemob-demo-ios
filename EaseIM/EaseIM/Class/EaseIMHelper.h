//
//  EaseIMHelper.h
//  EaseIM
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface EaseIMHelper : NSObject<EMMultiDevicesDelegate, EMContactManagerDelegate, EMGroupManagerDelegate, EMChatManagerDelegate, EMClientDelegate>

+ (instancetype)shareHelper;

@end
