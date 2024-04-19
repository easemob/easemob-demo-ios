//
//  MineConversationsController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/13.
//

import UIKit
import EaseChatUIKit

final class MineConversationsController: ConversationListController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigation.avatarURL = EaseChatUIKitContext.shared?.currentUser?.avatarURL
    }
    
    
    override func create(profiles: [EaseProfileProtocol]) {
        var name = ""
        var ids = [String]()
        for (index,profile) in profiles.enumerated() {
            if index <= 2 {
                if index == 0 {
                    name += (profile.nickname.isEmpty ? profile.id:profile.nickname)
                } else {
                    name += (", "+(profile.nickname.isEmpty ? profile.id:profile.nickname))
                }
            }
            ids.append(profile.id)
        }
        let option = ChatGroupOption()
        option.isInviteNeedConfirm = false
        option.maxUsers = Appearance.chat.groupParticipantsLimitCount
        option.style = .privateMemberCanInvite
        ChatClient.shared().groupManager?.createGroup(withSubject: name, description: "", invitees: ids, message: nil, setting: option, completion: { [weak self] group, error in
            if error == nil,let group = group {
                let profile = EaseProfile()
                profile.id = group.groupId
                profile.nickname = group.groupName
                self?.createChat(profile: profile, type: .groupChat,info: name)
                self?.fetchGroupAvatar(groupId: group.groupId)
                self?.autoDestroyGroupChat(groupId: group.groupId)
            } else {
                consoleLogInfo("create group error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }

    private func autoDestroyGroupChat(groupId: String) {
        EasemobBusinessRequest.shared.sendPOSTRequest(api: .autoDestroyGroup(groupId), params: [:]) { result, error in
            if error != nil {
                consoleLogInfo("autoDestroyGroupChat error:\(error?.localizedDescription ?? "")", type: .error)
            }
        }
    }
    
    private func fetchGroupAvatar(groupId: String) {
        EasemobBusinessRequest.shared.sendGETRequest(api: .fetchGroupAvatar(groupId), params: [:]) { [weak self] result,error in
            if error != nil {
                consoleLogInfo("fetchGroupAvatar error:\(error?.localizedDescription ?? "")", type: .error)
            } else {
                if let avatarURL = result?["avatarUrl"] as? String {
                    if let info = EaseChatUIKitContext.shared?.groupCache?[groupId] {
                        info.avatarURL = avatarURL
                        self?.viewModel?.renderDriver(infos: [info])
                    } else {
                        let info = EaseProfile()
                        info.id = groupId
                        info.avatarURL = avatarURL
                        self?.viewModel?.renderDriver(infos: [info])
                    }
                } else {
                    consoleLogInfo("fetchGroupAvatar error:\(result?["error"] as? String ?? "")", type: .error)
                }
            }
        }
    }
}
