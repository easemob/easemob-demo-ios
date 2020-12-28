//
//  EaseCallConfig.m
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/12/9.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import "EaseCallConfig.h"

@implementation EaseCallUser
- (instancetype)init
{
    self = [super init];
    if(self) {
        NSString* path = [NSString stringWithFormat:@"EaseCall.bundle/icon"];
        NSURL* url = [[NSBundle mainBundle] URLForResource:path withExtension:@"png"];
        self.headImage = url;
        self.nickName = @"";
        self.uId = @"";
    }
    return self;
}
@end

@implementation EaseCallConfig
- (instancetype)init
{
    self = [super init];
    if(self) {
        [self _initParams];
    }
    return self;
}

- (void)_initParams
{
    _callTimeOut = 30;
    NSString * imagePath = [[NSBundle mainBundle] pathForResource:@"EaseCall.bundle/placeHolder" ofType:@"png"];
    _placeHolderURL = [NSURL fileURLWithPath:imagePath];
    _users = [NSMutableDictionary dictionary];
    _title = @"多人会议";
    NSString * ringFilePath = [[NSBundle mainBundle] pathForResource:@"EaseCall.bundle/music" ofType:@"mp3"];
    _ringFileUrl = [NSURL fileURLWithPath:ringFilePath];
}

- (void)setPlaceHolderURL:(NSURL *)placeHolderURL
{
    if(placeHolderURL)
        _placeHolderURL = placeHolderURL;
}
@end
