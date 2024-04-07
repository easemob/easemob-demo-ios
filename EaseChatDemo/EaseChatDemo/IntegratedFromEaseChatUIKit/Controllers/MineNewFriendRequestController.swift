//
//  MineNewFriendRequestesController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/27.
//

import UIKit
import EaseChatUIKit
import SwiftFFDB

final class MineNewFriendRequestController: NewContactRequestController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func requestFriendInfo(userId: String) {
        ChatClient.shared().userInfoManager?.fetchUserInfo(byId: [userId], type: [0,1],completion: { infoMap, error in
            if error == nil,let info = infoMap?[userId] {
                let profile = EaseChatProfile()
                profile.id = userId
                profile.nickname = info.nickname ?? ""
                profile.avatarURL = info.avatarUrl ?? ""
                EaseChatUIKitContext.shared?.userCache?[userId] = profile
                profile.insert()
            } else {
                consoleLogInfo("requestFriendInfo error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }

    override func agreeFriendRequest(userId: String) {
        self.contactService.agreeFriendRequest(from: userId) { [weak self] error, userId in
            guard let self = self else { return }
            if error != nil,error?.code == .userAlreadyLoginAnother {
                consoleLogInfo("agreeFriendRequest error: \(error?.errorDescription ?? "")", type: .error)
            } else {
                self.showToast(toast: "agreeFriendRequest success".localized())
                self.newFriends.removeValue(forKey: userId)
                let conversation = ChatClient.shared().chatManager?.getConversation(userId, type: .chat, createIfNotExist: true)
                let ext = ["something":("You have added".chat.localize+" "+userId+" "+"to say hello".chat.localize)]
                let message = ChatMessage(conversationID: userId, body: ChatCustomMessageBody(event: EaseChatUIKit_alert_message, customExt: nil), ext: ext)
                conversation?.insert(message, error: nil)
                
                self.datas.removeAll()
                self.datas = self.fillDatas()
                self.datas.sort { $0.time > $1.time }
                if self.datas.count <= 0 {
                    self.requestList.backgroundView = self.empty
                } else {
                    self.requestList.backgroundView = nil
                }
                self.requestFriendInfo(userId: userId)
                self.requestList.reloadData()
            }
        }
    }
}
