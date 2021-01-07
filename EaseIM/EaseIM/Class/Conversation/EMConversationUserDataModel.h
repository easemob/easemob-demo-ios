//
//  EMConversationUserDataModel.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/12/6.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EaseIMKit/EaseIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMConversationUserDataModel : NSObject <EaseUserDelegate>

@property (nonatomic, copy, readonly) NSString *easeId;           // 环信id
@property (nonatomic, copy, readonly) UIImage *defaultAvatar;     // 默认头像显示

- (instancetype)initWithEaseId:(NSString*)easeId conversationType:(EMConversationType)type;

@end

NS_ASSUME_NONNULL_END
