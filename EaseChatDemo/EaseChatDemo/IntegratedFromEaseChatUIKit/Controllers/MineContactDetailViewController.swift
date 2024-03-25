//
//  MineContactDetailViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/19.
//

import UIKit
import EaseChatUIKit
import EaseCallKit
import SwiftFFDB

final class MineContactDetailViewController: ContactInfoViewController {
    
    override func dataSource() -> [DetailInfo] {
        [["title":"contact_details_button_remark".localized(),"detail":"","withSwitch": false,"switchValue":false],["title":"contact_details_switch_donotdisturb".chat.localize,"detail":"","withSwitch": true,"switchValue":self.muteMap[EaseChatUIKitContext.shared?.currentUserId ?? ""]?[self.profile.id] ?? 0 == 1],["title":"contact_details_button_clearchathistory".chat.localize,"detail":"","withSwitch": false,"switchValue":false]
        ].map {
            let info = DetailInfo()
            info.setValuesForKeys($0)
            return info
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestInfo()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    private func requestRemark() {
        let contact = ChatClient.shared().contactManager?.getAllContacts()?.first(where: { $0.userId == self.profile.id })
        let remark = contact?.remark ?? ""
        self.datas.first(where: { $0.title == "contact_details_button_remark".localized() })?.detail = remark
        self.menuList.reloadData()
        
        EaseChatUIKitContext.shared?.userCache?[self.profile.id]?.remark = remark
        
    }
    
    private func requestInfo() {
        ChatClient.shared().userInfoManager?.fetchUserInfo(byId: [self.profile.id], type: [0,1],completion: { [weak self] infoMap, error in
            guard let userId = self?.profile.id else { return }
            self?.requestRemark()
            if let info = infoMap?[userId],error == nil {
                DispatchQueue.main.async {
                    var remark = EaseChatUIKitContext.shared?.userCache?[userId]?.remark ?? ""
                    if remark.isEmpty {
                        remark = info.nickname ?? userId
                    }
                    self?.header.nickName.text = remark
                    self?.header.detailText = userId
                    self?.header.avatarURL = info.avatarUrl
                }
                if let profiles = EaseChatProfile.select(where: "id = ?",values: [userId]) as? [EaseChatProfile],let profile = profiles.first(where: { $0.id == userId }) {
                    profile.nickname = info.nickname ?? userId
                    profile.avatarURL = info.avatarUrl ?? ""
                    profile.update()
                    EaseChatUIKitContext.shared?.userCache?[userId] = profile
                } else {
                    let profile = EaseChatProfile()
                    profile.id = userId
                    profile.nickname = info.nickname ?? userId
                    profile.avatarURL = info.avatarUrl ?? ""
                    profile.insert()
                    EaseChatUIKitContext.shared?.userCache?[userId] = profile
                }
            } else {
                self?.showToast(toast: "fetchUserInfo error:\(error?.errorDescription ?? "")")
            }
        })
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
        case "AudioCall": self.startSingleCall(callType: .type1v1Audio)
        case "VideoCall": self.startSingleCall(callType: .type1v1Video)
        case "SearchMessages": self.searchHistoryMessages()
        default: break
        }
    }
    
    private func startSingleCall(callType: EaseCallType) {
        EaseCallManager.shared().startSingleCall(withUId: self.profile.id, type: callType, ext: nil) { [weak self] callId, callError in
            if callError != nil {
                self?.showToast(toast: "\(callError?.errDescription ?? "")")
            }
        }
    }
    
    override func didSelectRow(indexPath: IndexPath) {
        if let info = self.datas[safe: indexPath.row] {
            switch info.title {
            case "contact_details_button_clearchathistory".chat.localize:
                self.showClearChatHistoryAlert()
            case "contact_details_button_remark".localized():
                self.editRemark()
            default:
                break
            }
            
        }
        
    }
    
    private func showClearChatHistoryAlert() {
        DialogManager.shared.showAlert(title: "group_details_button_clearchathistory".chat.localize, content: "", showCancel: true, showConfirm: true) { [weak self] _ in
            guard let `self` = self else { return }
            ChatClient.shared().chatManager?.getConversationWithConvId(self.profile.id)?.deleteAllMessages(nil)
            NotificationCenter.default.post(name: Notification.Name("EaseChatUIKit_clean_history_messages"), object: self.profile.id)
        }
    }
    
    private func editRemark() {
        let vc = MineContactRemarkEditViewController(userId: self.profile.id, rawText: self.profile.remark) { [weak self] remark in
            guard let `self` = self else { return }
            self.profile.remark = remark
            self.datas.first?.detail = remark
            self.menuList.reloadData()
            EaseChatUIKitContext.shared?.userCache?[self.profile.id]?.remark = remark
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
