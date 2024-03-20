//
//  MineMessageListViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/14.
//

import UIKit
import EaseChatUIKit
import EaseCallKit

final class MineMessageListViewController: MessageListController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func rightImages() -> [UIImage] {
        var images = [UIImage(named: "message_action_topic", in: .chatBundle, with: nil)!,UIImage(named: "call", in: .chatBundle, with: nil)!]
        if !Appearance.chat.contentStyle.contains(.withMessageTopic) {
            images.remove(at: 0)
        }
        return images
    }
    
    override func rightItemsAction(indexPath: IndexPath?) {
        guard let idx = indexPath else { return }
        switch idx.row {
        case 0: !Appearance.chat.contentStyle.contains(.withMessageTopic) ? self.callAction():self.viewTopicList()
        case 1: self.callAction()
        default:
            break
        }
    }
    
    private func callAction() {
        if self.chatType == .chat {
            DialogManager.shared.showActions(actions: [ActionSheetItem(title: "Audio Call".localized(), type: .normal, tag: "AudioCall"),ActionSheetItem(title: "Video Call".localized(), type: .normal, tag: "VideoCall")]) { [weak self] item in
                self?.processItemAction(item: item)
            }
        } else {
            self.processItemAction(item: ActionSheetItem())
        }
    }
    
    private func processItemAction(item: ActionSheetItemProtocol) {
        if self.chatType == .chat {
            var callType = EaseCallType.type1v1Audio
            if item.tag == "VideoCall".localized() {
                callType = .type1v1Video
            }
            self.startSingleCall(callType: callType)
        } else {
            let vc = MineCallInviteUsersController(groupId: self.profile.id,profiles: []) { [weak self] users in
                let user = EaseChatUIKitContext.shared?.chatCache?[EaseChatUIKitContext.shared?.currentUserId ?? ""]
                var nickname = user?.id ?? ""
                if let realName = user?.nickname,!realName.isEmpty {
                    nickname = realName
                }
                if let remark = user?.remark,!remark.isEmpty {
                    nickname = remark
                }
                let text = "\(nickname)"+" start a multi call".localized()
                if let callMessage = self?.viewModel.constructMessage(text: text, type: .text, extensionInfo: ["ext":["groupId":self?.profile.id],"msgType":"2"]) {
                    callMessage.direction = .send
                    callMessage.timestamp = Int64(Date().timeIntervalSince1970*1000)
                    
                    callMessage.chatType = .groupChat
                    callMessage.status = .succeed
                    callMessage.isRead = true
                    ChatClient.shared().chatManager?.getConversationWithConvId(self?.profile.id)?.insert(callMessage, error: nil)
                    self?.viewModel.driver?.showMessage(message: callMessage)
                }
                self?.startGroupCall(users: users)
            }
            self.present(vc, animated: true)
            
        }
        
    }
    
    private func startSingleCall(callType: EaseCallType) {
        EaseCallManager.shared().startSingleCall(withUId: self.profile.id, type: callType, ext: nil) { [weak self]  _, _ in
            if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(self?.profile.id) {
                let messageId = conversation.latestMessage.messageId
                conversation.loadMessagesStart(fromId: messageId, count: 1, searchDirection:  messageId.isEmpty ? .down:.up) { messages, error in
                    if let message = messages?.first {
                        self?.messageContainer.showMessage(message: message)
                    }
                }
            }
        }
    }
    
    private func startGroupCall(users: [String]) {
        EaseCallManager.shared().startInviteUsers(users, ext: ["groupId":self.profile.id]) {  [weak self] _, _ in
            if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(self?.profile.id) {
                let messageId = conversation.latestMessage.messageId
                conversation.loadMessagesStart(fromId: messageId, count: 1, searchDirection:  messageId.isEmpty ? .down:.up) { messages, error in
                    if let message = messages?.first {
                        self?.messageContainer.showMessage(message: message)
                    }
                }
            }
        }
        
    }

    override func filterMessageActions(message: MessageEntity) -> [ActionSheetItemProtocol] {
        var messageActions = Appearance.chat.messageLongPressedActions
        if let ext = message.message.ext {
            if !ext.keys.contains("msgType") {
                return [
                    ActionSheetItem(title: "barrage_long_press_menu_delete".chat.localize, type: .normal,tag: "Delete",image: UIImage(named: "message_action_delete", in: .chatBundle, with: nil)),
                    ActionSheetItem(title: "barrage_long_press_menu_multi_select".chat.localize, type: .normal,tag: "MultiSelect",image: UIImage(named: "message_action_multi_select", in: .chatBundle, with: nil)),
                    ActionSheetItem(title: "barrage_long_press_menu_forward".chat.localize, type: .normal,tag: "Forward",image: UIImage(named: "message_action_forward", in: .chatBundle, with: nil))
                ]
            }
        }
        if message.message.body.type != .text {
            messageActions.removeAll { $0.tag == "Copy" }
            messageActions.removeAll { $0.tag == "Edit" }
            messageActions.removeAll { $0.tag == "Translate" }
            messageActions.removeAll { $0.tag == "OriginalText" }
        } else {
            if message.message.direction != .send {
                messageActions.removeAll { $0.tag == "Edit" }
            } else {
                if message.message.status != .succeed {
                    messageActions.removeAll { $0.tag == "Edit" }
                }
            }
            if Appearance.chat.enableTranslation {
                if message.showTranslation {
                    messageActions.removeAll { $0.tag == "Translate" }
                } else {
                    messageActions.removeAll { $0.tag == "OriginalText" }
                }
            } else {
                messageActions.removeAll { $0.tag == "Translate" }
                messageActions.removeAll { $0.tag == "OriginalText" }
            }
        }
        if !Appearance.chat.contentStyle.contains(.withReply) {
            messageActions.removeAll { $0.tag == "Reply" }
        }
        if !Appearance.chat.contentStyle.contains(.withMessageTopic) || message.message.chatType == .chat || message.message.chatThread != nil {
            messageActions.removeAll { $0.tag == "Topic" }
        }
        if message.message.direction != .send {
            messageActions.removeAll { $0.tag == "Recall" }
        } else {
            let duration = UInt(abs(Double(Date().timeIntervalSince1970) - Double(message.message.timestamp/1000)))
            if duration > Appearance.chat.recallExpiredTime {
                messageActions.removeAll { $0.tag == "Recall" }
            }
        }
        return messageActions
    }

}
