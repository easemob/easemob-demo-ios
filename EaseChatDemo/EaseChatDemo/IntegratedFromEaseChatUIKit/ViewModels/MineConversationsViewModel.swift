//
//  MineConversationsViewModel.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/19.
//

import UIKit
import EaseChatUIKit

final class MineConversationsViewModel: ConversationViewModel {
    
    override func conversationLastMessageUpdate(message: ChatMessage, info: ConversationInfo) {
        
        if let ext = message.ext?["ext"] as? Dictionary<String,String>,let groupId = ext["groupId"] {
            let callMessage = ChatMessage(conversationID: groupId, from: message.from, to: groupId ,body: message.body, ext: message.ext)
            callMessage.direction = .receive
            callMessage.timestamp = message.timestamp
            callMessage.localTime =  message.localTime
            callMessage.chatType = .groupChat
            callMessage.status = .succeed
            callMessage.isRead = true
            ChatClient.shared().chatManager?.getConversationWithConvId(groupId)?.insert(callMessage, error: nil)
            if groupId != message.conversationId {
                let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(message.conversationId)
                var error: ChatError?
                conversation?.deleteMessage(withId: message.messageId, error: &error)
                if error == nil {
                    if conversation?.latestMessage == nil {
                        ChatClient.shared().chatManager?.deleteConversation(message.conversationId, isDeleteMessages: true)
                    }
                }
            }
        }
        self.refreshUnreadCount(info: info)
    }
    
    private func refreshUnreadCount(info: ConversationInfo) {
        if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
            let items = self.mapper(objects: infos)
            var count = UInt(0)
            for item in items where item.doNotDisturb == false {
                count += item.unreadCount
            }
            self.service?.notifyUnreadCount(count: count)
            self.driver?.refreshList(infos: items)
            if !info.doNotDisturb,EaseChatUIKitClient.shared.option.option_chat.soundOnReceivedNewMessage,UIApplication.shared.applicationState == .active,self.chatId != info.id {
                self.playNewMessageSound()
            }
        }
    }

}
