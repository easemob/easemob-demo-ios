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

}
