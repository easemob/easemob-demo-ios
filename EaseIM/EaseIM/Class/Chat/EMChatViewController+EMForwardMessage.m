//
//  EMChatViewController+EMForwardMessage.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/11/28.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatViewController+EMForwardMessage.h"
#import "EMMsgTranspondViewController.h"

@implementation EMChatViewController (EMForwardMessage)

#pragma mark - Transpond Message

- (void)forwardMenuItemAction:(EMChatMessage *)message
{
    EMMsgTranspondViewController *controller = [[EMMsgTranspondViewController alloc] init];
    [self.navigationController pushViewController:controller animated:NO];
    __weak typeof(self) weakself = self;
    [controller setDoneCompletion:^(NSString * _Nonnull aUsername) {
        [weakself _forwardMsg:message toUser:aUsername];
    }];
}

- (void)_forwardMsg:(EMChatMessage *)message
               toUser:(NSString *)aUsername
{
    EMMessageBodyType type = message.body.type;
    if (type == EMMessageBodyTypeText || type == EMMessageBodyTypeLocation)
        [self _forwardMsgWithBody:message.body to:aUsername ext:message.ext completion:nil];
    if (type == EMMessageBodyTypeImage)
        [self _forwardImageMsg:message toUser:aUsername];
    if (type == EMMessageBodyTypeVideo)
        [self _forwardVideoMsg:message toUser:aUsername];
}

- (void)_forwardMsgWithBody:(EMMessageBody *)aBody
                         to:(NSString *)aTo
                        ext:(NSDictionary *)aExt
                 completion:(void (^)(EMChatMessage *message))aCompletionBlock
{
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMChatMessage *message = [[EMChatMessage alloc] initWithConversationID:aTo from:from to:aTo body:aBody ext:aExt];
    message.chatType = EMChatTypeChat;
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMChatMessage *message, EMError *error) {
        if (error) {
            [weakself.conversation deleteMessageWithId:message.messageId error:nil];
            [EMAlertController showErrorAlert:NSLocalizedString(@"forwardMsgFail", nil)];
        } else {
            if (aCompletionBlock) {
                aCompletionBlock(message);
            }
            [EMAlertController showSuccessAlert:NSLocalizedString(@"forwardMsgSucess", nil)];
            if ([aTo isEqualToString:weakself.conversation.conversationId]) {
                [weakself.conversation markMessageAsReadWithId:message.messageId error:nil];
                NSArray *formated = [weakself formatMessages:@[message]];
                [weakself.chatController.dataArray addObjectsFromArray:formated];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.chatController refreshTableView:YES];
                });
            }
        }
    }];
}

- (void)_forwardImageMsg:(EMChatMessage *)aMsg
                  toUser:(NSString *)aUsername
{
    EMImageMessageBody *newBody = nil;
    EMImageMessageBody *imgBody = (EMImageMessageBody *)aMsg.body;
    // 如果图片是己方发送，直接获取图片文件路径；若是对方发送，则需先查看原图（自动下载原图），再转发。
    if ([aMsg.from isEqualToString:EMClient.sharedClient.currentUsername]) {
        newBody = [[EMImageMessageBody alloc]initWithLocalPath:imgBody.localPath displayName:imgBody.displayName];
    } else {
        if (imgBody.downloadStatus != EMDownloadStatusSuccessed) {
            [EMAlertController showErrorAlert:NSLocalizedString(@"downloadImageFirst", nil)];
            return;
        }
        
        newBody = [[EMImageMessageBody alloc]initWithLocalPath:imgBody.localPath displayName:imgBody.displayName];
    }
    
    newBody.size = imgBody.size;
    __weak typeof(self) weakself = self;
    [weakself _forwardMsgWithBody:newBody to:aUsername ext:aMsg.ext completion:^(EMChatMessage *message) {
        
    }];
}

- (void)_forwardVideoMsg:(EMChatMessage *)aMsg
                  toUser:(NSString *)aUsername
{
    EMVideoMessageBody *oldBody = (EMVideoMessageBody *)aMsg.body;

    __weak typeof(self) weakself = self;
    void (^block)(EMChatMessage *aMessage) = ^(EMChatMessage *aMessage) {
        EMVideoMessageBody *newBody = [[EMVideoMessageBody alloc] initWithLocalPath:oldBody.localPath displayName:oldBody.displayName];
        newBody.thumbnailLocalPath = oldBody.thumbnailLocalPath;
        
        [weakself _forwardMsgWithBody:newBody to:aUsername ext:aMsg.ext completion:^(EMChatMessage *message) {
            [(EMVideoMessageBody *)message.body setLocalPath:[(EMVideoMessageBody *)aMessage.body localPath]];
            [[EMClient sharedClient].chatManager updateMessage:message completion:nil];
        }];
    };
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:oldBody.localPath]) {
        [[EMClient sharedClient].chatManager downloadMessageAttachment:aMsg progress:nil completion:^(EMChatMessage *message, EMError *error) {
            if (error) {
                [EMAlertController showErrorAlert:NSLocalizedString(@"forwardMsgFail", nil)];
            } else {
                block(aMsg);
            }
        }];
    } else {
        block(aMsg);
    }
}

@end
