//
//  MineConversationsController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/13.
//

import UIKit
import EaseChatUIKit

final class MineConversationsController: ConversationListController {
    private lazy var limitCount: UILabel = {
        UILabel(frame: CGRect(x: 0, y: 13, width: 50, height: 22)).font(UIFont.theme.bodyLarge).text("0/20").textColor(Theme.style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor7)
    }()
    
    private var limited = false
    
    private var customStatus = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigation.title = "Chats"
        self.listenToUserStatus()
        self.showUserStatus()
        self.previewRequestContact()
        self.navigation.separateLine.isHidden = true
    }
    
    override func navigationClick(type: ChatNavigationBarClickEvent, indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        case .rightItems: self.rightActions(indexPath: indexPath ?? IndexPath())
        case .avatar: self.showOnlineStatusDialog()
        default:
            break
        }
    }
    
    private func listenToUserStatus() {
        PresenceManager.shared.addHandler(handler: self)
    }
    
    private func showUserStatus() {
        if let presence = PresenceManager.shared.presences[ChatUIKitContext.shared?.currentUserId ?? ""] {
            let state = PresenceManager.status(with: presence)
            switch state {
            case .online:
                self.navigation.userState = .online
            case .offline:
                self.navigation.userState = .offline
            case .busy:
                self.navigation.status.image = nil
                self.navigation.status.backgroundColor = Theme.style == .dark ? UIColor.theme.errorColor5:UIColor.theme.errorColor6
            case .away:
                self.navigation.status.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
                self.navigation.status.image(PresenceManager.presenceImagesMap[.away] as? UIImage)
            case .doNotDisturb:
                self.navigation.status.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
                self.navigation.status.image(PresenceManager.presenceImagesMap[.doNotDisturb] as? UIImage)
            case .custom:
                self.navigation.status.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
                self.navigation.status.image(PresenceManager.presenceImagesMap[.custom] as? UIImage)
            }
            
        }
        
    }
    
    @objc func showOnlineStatusDialog() {
        let actions = [ActionSheetItem(title: "Online".localized(), type: .normal, tag: "online"),
                       ActionSheetItem(title: "Busy".localized(), type: .normal, tag: "busy"),
                       ActionSheetItem(title: "Do Not Disturb".localized(), type: .normal, tag: "disturb"),
                       ActionSheetItem(title: "Away".localized(), type: .normal, tag: "away"),
                       ActionSheetItem(title: "Custom Status".localized().localized(), type: .normal, tag: "custom_status")]
        DialogManager.shared.showActions(actions: actions) { [weak self] in
            self?.publishPresenceState(item: $0)
        }
    }
    
    @objc func publishPresenceState(item: ActionSheetItemProtocol) {
        var status: String?
        switch item.tag {
        case "busy":
            status = "\(PresenceManager.State.busy.rawValue)"
        case "disturb":
            status = "\(PresenceManager.State.doNotDisturb.rawValue)"
        case "away":
            status = "\(PresenceManager.State.away.rawValue)"
        case "custom_status":
            self.showCustomOnlineStatusAlert()
        default:
            break
        }
        self.limitCount.text = "0/20"
        PresenceManager.shared.publishPresence(description: status) { [weak self] error in
            if error != nil {
                self?.showToast(toast: "发布状态失败！")
            }
        }
    }
    
    @objc func showCustomOnlineStatusAlert() {
        let size = Appearance.alertContainerConstraintsSize
        let alert = AlertView().background(color: Theme.style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor98).title(title: "Custom Status".localized()).cornerRadius(Appearance.alertStyle == .small ? .extraSmall:.medium).titleColor(color: Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        alert.textField(font: UIFont.theme.bodyLarge).textField(color: Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1).textFieldPlaceholder(color: Theme.style == .dark ? UIColor.theme.neutralColor5:UIColor.theme.neutralColor6).textFieldPlaceholder(placeholder: "Please input".chat.localize).textFieldRadius(cornerRadius: Appearance.alertStyle == .small ? .extraSmall:.medium).textFieldBackground(color: Theme.style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor95).textFieldDelegate(delegate: self).textFieldRightView(rightView: UIView {
            UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)).backgroundColor(.clear)
            self.limitCount
        })
        alert.textField.becomeFirstResponder()
        alert.leftButton(color: Theme.style == .dark ? UIColor.theme.neutralColor95:UIColor.theme.neutralColor3).leftButtonBorder(color: Theme.style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor7).leftButton(title: "report_button_click_menu_button_cancel".chat.localize).leftButtonRadius(cornerRadius: Appearance.alertStyle == .small ? .extraSmall:.large)
        alert.rightButtonBackground(color: Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor).rightButton(color: UIColor.theme.neutralColor98).rightButtonTapClosure { [weak self] _ in
            guard let `self` = self else { return }
            if self.limited {
                self.showToast(toast: "The length of the custom status should be less than 20 characters".chat.localize)
                return
            } else {
                self.limitCount.text = "0/20"
                PresenceManager.shared.publishPresence(description: self.customStatus) { [weak self] error in
                    if error != nil {
                        self?.showToast(toast: "发布状态失败！")
                    }
                }
            }
        }.rightButton(title: "Confirm".chat.localize).rightButtonRadius(cornerRadius: Appearance.alertStyle == .small ? .extraSmall:.large)
        let alertVC = AlertViewController(custom: alert,size: size, customPosition: true)
        let vc = UIViewController.currentController
        if vc != nil {
            vc?.presentViewController(alertVC)
        }
    }
    
    private func publishCustomStatus() {
        PresenceManager.shared.publishPresence(description: self.customStatus) { [weak self] error in
            if error != nil {
                self?.showToast(toast: "自定义状态设置失败")
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigation.avatarURL = ChatUIKitContext.shared?.currentUser?.avatarURL
    }
    
    
    override func create(profiles: [ChatUserProfileProtocol]) {
        var name = ""
        var users = [ChatUserProfileProtocol]()
        let ownerId = ChatUIKitContext.shared?.currentUserId ?? ""
        if let owner = ChatUIKitContext.shared?.userCache?[ownerId] {
            users.append(owner)
            users.append(contentsOf: profiles)
        }
        var ids = [String]()
        for (index,profile) in users.enumerated() {
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
                let profile = ChatUserProfile()
                profile.id = group.groupId
                profile.nickname = group.groupName
                self?.createChat(profile: profile, type: .groupChat,info: name)
                self?.fetchGroupAvatar(groupId: group.groupId)
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
                    if let info = ChatUIKitContext.shared?.groupCache?[groupId] {
                        info.avatarURL = avatarURL
                        self?.viewModel?.renderDriver(infos: [info])
                    } else {
                        let info = ChatUserProfile()
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
    
    private func previewRequestContact() {
        let contacts = ChatClient.shared().contactManager?.getContacts() ?? []
        let loadFinish = UserDefaults.standard.bool(forKey: "EaseChatUIKit_contact_fetch_server_finished"+saveIdentifier)
        if !loadFinish,contacts.count <= 0 {
            ChatClient.shared().contactManager?.getContactsFromServer(completion: { users, error in
                if error == nil {
                    UserDefaults.standard.set(true, forKey: "EaseChatUIKit_contact_fetch_server_finished"+saveIdentifier)
                }
            })
        }
    }
    
    override func addContact() {
        DialogManager.shared.showAlert(title: "new_chat_button_click_menu_addcontacts".chat.localize, content:
                                        "add_contacts_subtitle".chat.localize, showCancel: true, showConfirm: true,showTextFiled: true,placeHolder: "contactID".localized()) { [weak self] text in
            self?.addContactRequest(text: text)
        }
    }    
    
    @objc public func addContactRequest(text: String) {
        if text.chat.numCount != 11 {
            ChatClient.shared().contactManager?.addContact(text, message: "", completion: { [weak self]  userId,error  in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.showToast(toast: "add contact error:\(error.errorDescription ?? "")")
                    }
                    consoleLogInfo("add contact error:\(error.errorDescription ?? "")", type: .error)
                } else {
                    DispatchQueue.main.async {
                        self?.showToast(toast: "Friend request sent".localized())
                    }
                }
            })
            return
        }
        EasemobBusinessRequest.shared.sendGETRequest(api: .addFriendByPhoneNumber(text, ChatUIKitContext.shared?.currentUserId ?? ""), params: [:]) { [weak self] result, error in
            if error != nil,let someError  = error as? EasemobError,someError.code == "404" {
                DispatchQueue.main.async {
                    self?.showToast(toast: "The user does not exist".localized())
                }
            } else {
                if let userId = result?["chatUserName"] as? String {
                    ChatClient.shared().contactManager?.addContact(userId, message: "", completion: {  userId,error  in
                        if let error = error {
                            consoleLogInfo("add contact error:\(error.errorDescription ?? "")", type: .error)
                        } else {
                            DispatchQueue.main.async {
                                self?.showToast(toast: "Friend request sent".localized())
                            }
                        }
                    })
                }
                
            }
        }
    }
}

extension MineConversationsController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.customStatus = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if self.customStatus.count > 0 {
            self.limited = self.customStatus.count > 20
            self.limitCount.text = "\(self.customStatus.count)/20"
            if self.customStatus.count > 20 {
                self.limitCount.textColor = Theme.style == .dark ? UIColor.theme.errorColor5:UIColor.theme.errorColor6
            } else {
                self.limitCount.textColor = Theme.style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor7
            }
        } else {
            self.limitCount.text = "0/20"
        }
        return true
    }
}

extension MineConversationsController: PresenceDidChangedListener {
    func presenceStatusChanged(users: [String]) {
        self.showUserStatus()
    }
    
    override func switchTheme(style: ThemeStyle) {
        super.switchTheme(style: style)
        let image = UIImage(named: style == .dark ? "conversation_ondark":"conversation_onlight") ?? UIImage()
        self.navigation.updateRightItems(images: [image], original: true)
        self.navigation.titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        self.navigation.titleLabel.textColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor)
    }
}

extension UIFont {
    static func customFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let fontName: String
        switch weight {
        case .light:
            fontName = "chatfontVF-Light"
        case .regular:
            fontName = "chatfontVF-Regular"
        case .bold:
            fontName = "chatfontVF-Bold"
        case .semibold:
            fontName = "chatfontVF-semibold"
        default:
            fontName = "chatfontVF-semibold"
        }
        
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
}

// 使用
let lightFont = UIFont.customFont(ofSize: 17, weight: .light)
let regularFont = UIFont.customFont(ofSize: 17, weight: .regular)
let boldFont = UIFont.customFont(ofSize: 17, weight: .bold)
