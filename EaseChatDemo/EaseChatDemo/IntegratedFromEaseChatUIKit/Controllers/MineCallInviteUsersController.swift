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
    
    private var existProfiles = [EaseProfileProtocol]()
    
    public required init(groupId: String, profiles: [EaseProfileProtocol],usersClosure: @escaping ([String]) -> Void) {
        super.init(group: ChatGroup(id: groupId), profiles: profiles, removeClosure: usersClosure)
        self.existProfiles = profiles
        self.confirmClosure = usersClosure
    }
    
    required init(group: ChatGroup, profiles: [EaseProfileProtocol], removeClosure: @escaping ([String]) -> Void) {
        super.init(group: group, profiles: profiles, removeClosure: removeClosure)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createNavigation() -> EaseChatNavigationBar {
        EaseChatNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44),textAlignment: .left,rightTitle: "Confirm".chat.localize)
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
        self.service.fetchParticipants(groupId: self.chatGroup.groupId, cursor: "", pageSize: 200) { [weak self] result, error in
            guard let `self` = self else {return}
            if error == nil {
                self.participants = (result?.list ?? []).map({
                    let profile = EaseProfile()
                    profile.id = $0 as String
                    if let user = EaseChatUIKitContext.shared?.chatCache?[$0 as String] {
                        var nickname = profile.nickname
                        nickname = user.remark
                        if nickname.isEmpty {
                            nickname = user.nickname
                        }
                        if nickname.isEmpty {
                            nickname = profile.id
                        }
                        profile.nickname = nickname
                        profile.avatarURL = user.avatarURL
                    }
                    return profile
                })
                for profile in self.existProfiles {
                    self.participants.removeAll { $0.id == profile.id }
                }
                self.participantsList.reloadData()
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
        self.navigation.rightItem.setTitleColor(style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5, for: .normal)
    }
}
