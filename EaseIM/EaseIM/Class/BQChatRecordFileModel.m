//
//  BQChatRecordFileModel.m
//  EaseIM
//
//  Created by liu001 on 2022/7/12.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQChatRecordFileModel.h"

@implementation BQChatRecordFileModel

- (instancetype)initWithMessage:(EMChatMessage *)msg time:(NSString *)timestamp
{
    self = [super init];
    if (self) {
        _avatarImg = ImageWithName(@"jh_user_icon");
        _message = msg;
        _from = msg.from;
        NSString *fileName = [NSString stringWithFormat:@"[%@]",((EMFileMessageBody *)msg.body).displayName];
        _filename = fileName;
        _timestamp = timestamp;
    }
    return self;
}



@end
