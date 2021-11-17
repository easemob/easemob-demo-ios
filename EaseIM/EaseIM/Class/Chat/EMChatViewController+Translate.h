//
//  EMChatViewController+Translate.h
//  EaseIM
//
//  Created by lixiaoming on 2021/11/16.
//  Copyright © 2021 lixiaoming. All rights reserved.
//

#import "EMChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatViewController (Translate)
// 正在翻译的消息，需要显示loading
@property (nonatomic, strong) NSMutableSet<NSString*>* translatingMsgIds;
@end

NS_ASSUME_NONNULL_END
