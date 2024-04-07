//
//  MineConversationsViewModel.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/19.
//

import UIKit
import EaseChatUIKit

final class MineConversationsViewModel: ConversationViewModel {
    
    @objc override func mapper(objects: [ChatConversation]) -> [ConversationInfo] {
        objects.map {
            let conversation = ComponentsRegister.shared.Conversation.init()
            conversation.id = $0.conversationId
            var nickname = ""
            var profile: EaseProfileProtocol?
            if $0.type == .chat {
                profile = EaseChatUIKitContext.shared?.userCache?[$0.conversationId]
            } else {
                profile = EaseChatUIKitContext.shared?.groupCache?[$0.conversationId]
                if EaseChatUIKitContext.shared?.groupProfileProvider == nil,EaseChatUIKitContext.shared?.groupProfileProviderOC == nil {
                    profile?.nickname = ChatGroup(id: $0.conversationId).groupName ?? ""
                }
            }
            if nickname.isEmpty {
                nickname = profile?.remark ?? ""
            }
            if nickname.isEmpty {
                nickname = profile?.nickname ?? ""
            }
            if nickname.isEmpty {
                nickname = $0.conversationId
            }
            conversation.unreadCount = UInt($0.unreadMessagesCount)
            conversation.lastMessage = $0.latestMessage
            conversation.type = EaseProfileProviderType(rawValue: UInt($0.type.rawValue)) ?? .chat
            conversation.pinned = $0.isPinned
            conversation.nickname = profile?.nickname ?? ""
            conversation.remark = profile?.remark ?? ""
            conversation.avatarURL = profile?.avatarURL ?? ""
            conversation.doNotDisturb = false
            if let silentMode = self.muteMap[EaseChatUIKitContext.shared?.currentUserId ?? ""]?[$0.conversationId] {
                conversation.doNotDisturb = silentMode != 0
            }
            
            _ = conversation.showContent
            return conversation
        }
    }
    
    override func conversationLastMessageUpdate(message: ChatMessage, info: ConversationInfo) {
        super.conversationLastMessageUpdate(message: message, info: info)
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
