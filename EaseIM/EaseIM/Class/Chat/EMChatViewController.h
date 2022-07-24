//
//  EMChatViewController.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/11/27.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMChatViewController : UIViewController
@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) EaseChatViewController *chatController;
//查找消息记录搜索到的消息
@property (nonatomic, strong) EMChatMessage *chatRecordKeyMessage;

- (instancetype)initWithConversationId:(NSString *)conversationId conversationType:(EMConversationType)conType;
//本地通话记录
- (void)insertLocationCallRecord:(NSNotification*)noti;

- (NSArray *)formatMessages:(NSArray<EMChatMessage *> *)aMessages;

//- (void)scrollToAssignMessage:(EMChatMessage *)message;


@end

NS_ASSUME_NONNULL_END
