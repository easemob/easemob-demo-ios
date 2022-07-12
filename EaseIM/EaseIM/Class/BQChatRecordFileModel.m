//
//  BQChatRecordFileModel.m
//  EaseIM
//
//  Created by liu001 on 2022/7/12.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQChatRecordFileModel.h"

@implementation BQChatRecordFileModel

- (instancetype)initWithInfo:(NSString *)keyWord img:(UIImage *)img msg:(EMChatMessage *)msg time:(NSString *)timestamp
{
    self = [super init];
    if (self) {
        _avatarImg = img;
        _from = msg.from;
        NSString *fileName = [NSString stringWithFormat:@"[%@]",((EMFileMessageBody *)msg.body).displayName];
        
        NSRange range = [fileName rangeOfString:keyWord options:NSCaseInsensitiveSearch];
        
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:fileName];
        if(range.length > 0) {
   
            [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#4798CB"]} range:NSMakeRange(range.location, keyWord.length)];

        }
        _detail = attributedStr;
        _timestamp = timestamp;
    }
    return self;
}

@end
