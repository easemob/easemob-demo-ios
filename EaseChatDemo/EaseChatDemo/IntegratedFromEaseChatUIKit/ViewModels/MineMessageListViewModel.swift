//
//  MineMessageListViewModel.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/14.
//

import UIKit
import EaseChatUIKit

final class MineMessageListViewModel: MessageListViewModel {
    
    
    @UserDefault("EaseChatUIKit_conversation_mute_map", defaultValue: Dictionary<String,Dictionary<String,Int>>()) public private(set) var muteMap
    
    @objc private func mapper(objects: [ChatConversation]) -> [ConversationInfo] {
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

    override func messageDidReceived(message: ChatMessage) {
        if message.conversationId == self.to {
            if let dic = message.ext?["ease_chat_uikit_user_info"] as? Dictionary<String,Any> {
                let profile = EaseProfile()
                profile.setValuesForKeys(dic)
                profile.id = message.from
                profile.modifyTime = message.timestamp
                EaseChatUIKitContext.shared?.chatCache?[message.from] = profile
            }
            let entity = message
            entity.direction = message.direction
            if let scrolledBottom = self.driver?.scrolledBottom,scrolledBottom {
                let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(self.to)
                conversation?.markMessageAsRead(withId: message.messageId, error: nil)
                if conversation?.type ?? .chat == .chat {
                    switch message.body.type {
                    case .text,.location,.custom,.image:
                        ChatClient.shared().chatManager?.sendMessageReadAck(message.messageId, toUser: self.to)
                    default:
                        break
                    }
                }
            }
            self.driver?.showMessage(message: entity)
        } else {
            if let ext = message.ext?["ext"] as? Dictionary<String,String>,let groupId = ext["groupId"] {
                let callMessage = ChatMessage(conversationID: groupId, from: message.from, to: groupId ,body: message.body, ext: message.ext)
                callMessage.direction = .receive
                callMessage.timestamp = message.timestamp
                callMessage.localTime =  message.localTime
                callMessage.chatType = .groupChat
                callMessage.status = .succeed
                callMessage.isRead = true
                ChatClient.shared().chatManager?.getConversationWithConvId(groupId)?.insert(callMessage, error: nil)
                if groupId == self.to {
                    self.deleteMessage(message: message)
                    self.driver?.showMessage(message: callMessage)
                } else {
                    ChatClient.shared().chatManager?.getConversationWithConvId(message.to)?.deleteMessage(withId: message.messageId, error: nil)
                    
                }
                
            }
        }
    }
}
