//
//  MineCallInviteUsersController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/14.
//

import UIKit
import EaseChatUIKit

final class MineCallInviteUsersController: GroupParticipantsRemoveController {
        
    private var confirmClosure: (([String]) -> Void)?
    
    private var existProfiles = [ChatUserProfileProtocol]()
    
    private var pageSize = UInt(200)
    
    private var cursor = ""
    
    public required init(groupId: String, profiles: [ChatUserProfileProtocol],usersClosure: @escaping ([String]) -> Void) {
        super.init(group: ChatGroup(id: groupId), profiles: profiles, removeClosure: usersClosure)
        self.existProfiles = profiles
        self.confirmClosure = usersClosure
    }
    
    required init(group: ChatGroup, profiles: [ChatUserProfileProtocol], removeClosure: @escaping ([String]) -> Void) {
        super.init(group: group, profiles: profiles, removeClosure: removeClosure)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createNavigation() -> ChatNavigationBar {
        ChatNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44),textAlignment: .left,rightTitle: "Confirm".chat.localize)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.cornerRadius(.medium, [.topLeft,.topRight], .clear, 0)
        // Do any additional setup after loading the view.
        self.navigation.title = "Video Call".localized()
        self.navigation.rightItem.title("Confirm".chat.localize, .normal)
        self.fetchParticipants()
        self.switchTheme(style: Theme.style)
    }
    
    private func fetchParticipants() {
        self.service.fetchParticipants(groupId: self.chatGroup.groupId, cursor: self.cursor, pageSize: self.pageSize) { [weak self] result, error in
            guard let `self` = self else {return}
            if error == nil {
                if let list = result?.list {
                    if self.cursor.isEmpty {
                        self.participants.removeAll()
                        self.participants = list.map({
                            let profile = ChatUserProfile()
                            let id = $0 as String
                            profile.id = id
                            if let user = ChatUIKitContext.shared?.userCache?[id] {
                                profile.nickname = user.nickname
                                profile.avatarURL = user.avatarURL
                            }
                            if let user = ChatUIKitContext.shared?.chatCache?[id] {
                                profile.nickname = user.nickname
                                profile.avatarURL = user.avatarURL
                            }
                            
                            return profile
                        })
                        if list.count <= self.pageSize {
                            let profile = ChatUserProfile()
                            profile.id = self.chatGroup.owner
                            if let user = ChatUIKitContext.shared?.userCache?[self.chatGroup.owner] {
                                profile.nickname = user.nickname
                                profile.avatarURL = user.avatarURL
                            }
                            if let user = ChatUIKitContext.shared?.chatCache?[self.chatGroup.owner] {
                                profile.nickname = user.nickname
                                profile.avatarURL = user.avatarURL
                            }
                            self.participants.insert(profile, at: 0)
                        }
                    } else {
                        self.participants.append(contentsOf: list.map({
                            let profile = ChatUserProfile()
                            profile.id = $0 as String
                            if let user = ChatUIKitContext.shared?.userCache?[profile.id] {
                                profile.nickname = user.nickname
                                profile.avatarURL = user.avatarURL
                            }
                            if let user = ChatUIKitContext.shared?.chatCache?[profile.id] {
                                profile.nickname = user.nickname
                                profile.avatarURL = user.avatarURL
                            }
                            return profile
                        }))
                        
                    }
                }
                self.cursor = result?.cursor ?? ""
                self.participants.removeAll { $0.id == ChatUIKitContext.shared?.currentUserId ?? "" }
                self.participantsList.reloadData()
                if !self.cursor.isEmpty {
                    self.fetchParticipants()
                }
            } else {
                self.showToast(toast: error?.errorDescription ?? "Failed to fetch participants")
            }
        }
    }
    
    override func didSelectRowAt(indexPath: IndexPath) {
        if let profile = self.participants[safe: indexPath.row] {
            profile.selected = !profile.selected
            self.participantsList.reloadData()
        }
        let count = self.participants.filter({ $0.selected }).count
        if count > 0 {
            self.navigation.rightItem.isEnabled = true
            self.navigation.rightItem.title("Confirm".chat.localize+"(\(count))", .normal)
        } else {
            self.navigation.rightItem.title("Confirm".chat.localize, .normal)
            self.navigation.rightItem.isEnabled = false
        }
    }
    
    override func rightAction() {
        let userIds = self.participants.filter { $0.selected == true }.map { $0.id }
        self.confirmClosure?(userIds)
        self.pop()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func switchTheme(style: ThemeStyle) {
        super.switchTheme(style: style)
        self.navigation.rightItem.setTitleColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor, for: .normal)
    }
}
