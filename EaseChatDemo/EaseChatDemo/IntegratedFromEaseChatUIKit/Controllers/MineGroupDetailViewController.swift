//
//  MineGroupDetailViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/19.
//

import UIKit
import EaseChatUIKit
import EaseCallKit

final class MineGroupDetailViewController: GroupInfoViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func headerActions() {
        super.headerActions()
        if let audioCall = Appearance.contact.detailExtensionActionItems.first(where: { $0.featureIdentify == "AudioCall" }) {
            audioCall.actionClosure = { [weak self] in
                self?.processHeaderActionEvents(item: $0)
            }
        }
        if let videoCall = Appearance.contact.detailExtensionActionItems.first(where: { $0.featureIdentify == "VideoCall" }) {
            videoCall.actionClosure = { [weak self] in
                self?.processHeaderActionEvents(item: $0)
            }
        }
    }
    
    override func processHeaderActionEvents(item: any ContactListHeaderItemProtocol) {
        switch item.featureIdentify {
        case "Chat": self.alreadyChat()
        case "AudioCall": self.groupCall()
        case "VideoCall": self.groupCall()
        case "SearchMessages": self.searchHistoryMessages()
        default: break
        }
    }
    
    private func groupCall() {
        guard let groupId = self.chatGroup.groupId else {
            self.showToast(toast: "Chat group id is nil")
            return
        }
        let vc = MineCallInviteUsersController(groupId: groupId,profiles: []) { [weak self] users in
            let user = EaseChatUIKitContext.shared?.chatCache?[EaseChatUIKitContext.shared?.currentUserId ?? ""]
            self?.startGroupCall(users: users)
        }
        self.present(vc, animated: true)
    }

    private func startGroupCall(users: [String]) {
        if let groupId = self.chatGroup.groupId {
            EaseCallManager.shared().startInviteUsers(users, ext: ["groupId":groupId]) {  [weak self] callId, callError in
                if callError != nil {
                    self?.showToast(toast: "\(callError?.errDescription ?? "")")
                }
            }
        }
    }
}
