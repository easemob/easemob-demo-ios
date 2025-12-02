//
//  MainViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/5.
//

import UIKit
import EaseChatUIKit
import EaseCallUIKit
import SwiftFFDBHotFix
import PhotosUI
import AgoraRtcKit

final class MainViewController: UITabBarController {
    
    private lazy var chats: ConversationListController = {
        let vc = EaseChatUIKit.ComponentsRegister.shared.ConversationsController.init()
        vc.tabBarItem.tag = 0
        vc.viewModel?.registerEventsListener(listener: self)
        return vc
    }()
    
    private lazy var contacts: ContactViewController = {
        let vc = EaseChatUIKit.ComponentsRegister.shared.ContactsController.init(headerStyle: .contact)
        vc.tabBarItem.tag = 1
        vc.viewModel?.registerEventsListener(self)
        return vc
    }()
    
    private lazy var me: MeViewController = {
        let vc = MeViewController()
        vc.tabBarItem.tag = 2
        return vc
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIApplication.shared.chat.keyWindow != nil {
            tabBar.frame = CGRect(x: 0, y: EaseChatUIKit.ScreenHeight-EaseChatUIKit.BottomBarHeight-49, width: EaseChatUIKit.ScreenWidth, height: EaseChatUIKit.BottomBarHeight+49)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.insetsLayoutMarginsFromSafeArea = false
        self.tabBarController?.additionalSafeAreaInsets = .zero
        self.callKitSet()
        self.setupDataProvider()
        self.loadViewControllers()
        // Do any additional setup after loading the view.
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.updateContactBadge()
    }
    
    private func setupDataProvider() {
        //userProfileProvider为用户数据的提供者，使用协程实现与userProfileProviderOC不能同时存在userProfileProviderOC使用闭包实现
        ChatUIKitContext.shared?.userProfileProvider = self
        ChatUIKitContext.shared?.userProfileProviderOC = nil
        //groupProvider原理同上
        ChatUIKitContext.shared?.groupProfileProvider = self
        ChatUIKitContext.shared?.groupProfileProviderOC = nil
    }
    
    private func callKitSet() {
        //接入环信CallKit
        if let currentUser = ChatUIKitContext.shared?.currentUser {
            let profile = CallUserProfile()
            profile.id = currentUser.id
            profile.nickname = currentUser.nickname
            profile.avatarURL = currentUser.avatarURL
            CallKitManager.shared.currentUserInfo = profile
        }
        CallKitManager.shared.profileProvider = self
        CallKitManager.shared.addListener(self)
    }

    private func loadViewControllers() {

        let nav1 = UINavigationController(rootViewController: self.chats)
        nav1.interactivePopGestureRecognizer?.isEnabled = true
        nav1.interactivePopGestureRecognizer?.delegate = self
        let nav2 = UINavigationController(rootViewController: self.contacts)
        nav2.interactivePopGestureRecognizer?.isEnabled = true
        nav2.interactivePopGestureRecognizer?.delegate = self
        let nav3 = UINavigationController(rootViewController: self.me)
        nav3.interactivePopGestureRecognizer?.isEnabled = true
        nav3.interactivePopGestureRecognizer?.delegate = self
        self.viewControllers = [nav1, nav2,nav3]
        self.view.backgroundColor = UIColor.theme.neutralColor98
        self.tabBar.backgroundColor = UIColor.theme.barrageDarkColor8
        self.tabBar.barTintColor = UIColor.theme.barrageDarkColor8
        self.tabBar.isTranslucent = true
        self.tabBar.barStyle = .default
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
    }

}

extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
            return self.navigationController!.viewControllers.count > 1
        }
        if UIViewController.currentController is MineConversationsController || UIViewController.currentController is MineContactsViewController || UIViewController.currentController is MeViewController {
            return false
        }
        return true
    }
}

extension MainViewController: EaseChatUIKit.ThemeSwitchProtocol {
    
    func switchTheme(style: EaseChatUIKit.ThemeStyle) {
        self.tabBar.barTintColor = style == .dark ? UIColor.theme.barrageLightColor8:UIColor.theme.barrageDarkColor8
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.tabBar.backgroundColor = style == .dark ? UIColor.theme.barrageLightColor8:UIColor.theme.barrageDarkColor8
        
        var chatsImage = UIImage(named: "tabbar_chats")
        chatsImage = chatsImage?.withTintColor(style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor5, renderingMode: .alwaysOriginal)
        let selectedChatsImage = chatsImage?.withTintColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor, renderingMode: .alwaysOriginal)
        self.chats.tabBarItem = UITabBarItem(title: "Chats".localized(), image: chatsImage, selectedImage: selectedChatsImage)
        
        self.chats.tabBarItem.setTitleTextAttributes([.foregroundColor:UIColor(0x999999)], for: .normal)
        self.chats.tabBarItem.setTitleTextAttributes([.foregroundColor:UIColor(0x007AFF)], for: .selected)
        
        var contactImage = UIImage(named: "tabbar_contacts")
        contactImage = contactImage?.withTintColor(style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor5, renderingMode: .alwaysOriginal)
        let selectedContactImage = contactImage?.withTintColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor, renderingMode: .alwaysOriginal)
        self.contacts.tabBarItem = UITabBarItem(title: "Contacts".localized(), image: contactImage, selectedImage: selectedContactImage)
        self.contacts.tabBarItem.setTitleTextAttributes([.foregroundColor:UIColor(0x999999)], for: .normal)
        self.contacts.tabBarItem.setTitleTextAttributes([.foregroundColor:UIColor(0x007AFF)], for: .selected)
        
        var meImage = UIImage(named: "tabbar_mine")
        meImage = meImage?.withTintColor(style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor5, renderingMode: .alwaysOriginal)
        let selectedMeImage = meImage?.withTintColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor, renderingMode: .alwaysOriginal)
        self.me.tabBarItem = UITabBarItem(title: "Me".localized(), image: meImage, selectedImage: selectedMeImage)
        
        self.me.tabBarItem.setTitleTextAttributes([.foregroundColor:UIColor(0x999999)], for: .normal)
        self.me.tabBarItem.setTitleTextAttributes([.foregroundColor:UIColor(0x007AFF)], for: .selected)
        self.tabBar.layoutIfNeeded()
        
    }
    
}

//MARK: - EaseProfileProvider for conversations&contacts usage.
//For example using conversations controller,as follows.
extension MainViewController: ChatUserProfileProvider,ChatGroupProfileProvider {
    //MARK: - EaseProfileProvider
    func fetchProfiles(profileIds: [String]) async -> [any EaseChatUIKit.ChatUserProfileProtocol] {
        consoleLogInfo("fetchProfiles", type: .error)
        return await withTaskGroup(of: [EaseChatUIKit.ChatUserProfileProtocol].self, returning: [EaseChatUIKit.ChatUserProfileProtocol].self) { group in
            var resultProfiles: [EaseChatUIKit.ChatUserProfileProtocol] = []
            group.addTask {
                var resultProfiles: [EaseChatUIKit.ChatUserProfileProtocol] = []
                let result = await self.requestUserInfos(profileIds: profileIds)
                if let infos = result {
                    resultProfiles.append(contentsOf: infos)
                }
                return resultProfiles
            }
            //Await all task were executed.Return values.
            for await result in group {
                resultProfiles.append(contentsOf: result)
            }
            return resultProfiles
        }
    }
    //MARK: - EaseGroupProfileProvider
    func fetchGroupProfiles(profileIds: [String]) async -> [any EaseChatUIKit.ChatUserProfileProtocol] {
        consoleLogInfo("fetchGroupProfiles", type: .error)
        return await withTaskGroup(of: [EaseChatUIKit.ChatUserProfileProtocol].self, returning: [EaseChatUIKit.ChatUserProfileProtocol].self) { group in
            var resultProfiles: [EaseChatUIKit.ChatUserProfileProtocol] = []
            group.addTask {
                var resultProfiles: [EaseChatUIKit.ChatUserProfileProtocol] = []
                let result = await self.requestGroupsInfo(groupIds: profileIds)
                if let infos = result {
                    resultProfiles.append(contentsOf: infos)
                }
                return resultProfiles
            }
            //Await all task were executed.Return values.
            for await result in group {
                resultProfiles.append(contentsOf: result)
            }
            return resultProfiles
        }
    }
    
    private func requestUserInfos(profileIds: [String]) async -> [ChatUserProfileProtocol]? {
        var unknownIds = [String]()
        var resultProfiles = [ChatUserProfileProtocol]()
        for profileId in profileIds {
            if let profile = ChatUIKitContext.shared?.userCache?[profileId] {
                resultProfiles.append(profile)
            } else {
                unknownIds.append(profileId)
            }
        }
        if unknownIds.isEmpty {
            return resultProfiles
        }
        let result = await ChatClient.shared().userInfoManager?.fetchUserInfo(byId: unknownIds)
        if result?.1 == nil,let infoMap = result?.0 {
            for (userId,info) in infoMap {
                let profile = EaseChatProfile()
                let nickname = info.nickname ?? ""
                profile.id = userId
                profile.nickname = nickname
                profile.modifyTime = Int64(Date().timeIntervalSince1970*1000)
                if let remark = ChatClient.shared().contactManager?.getContact(userId)?.remark {
                    profile.remark = remark
                }
                profile.avatarURL = info.avatarUrl ?? ""
                resultProfiles.append(profile)
                if (ChatUIKitContext.shared?.userCache?[userId]) != nil {
                    profile.updateFFDB()
                } else {
                    profile.insert()
                }
                ChatUIKitContext.shared?.userCache?[userId] = profile
            }
            return resultProfiles
        }
        return []
    }
    
    private func requestGroupsInfo(groupIds: [String]) async -> [ChatUserProfileProtocol]? {
        var resultProfiles = [ChatUserProfileProtocol]()
        let groups = ChatClient.shared().groupManager?.getJoinedGroups() ?? []
        for groupId in groupIds {
            if let group = groups.first(where: { $0.groupId == groupId }) {
                let profile = EaseChatProfile()
                profile.id = groupId
                profile.nickname = group.groupName
                profile.avatarURL = group.settings.ext
                resultProfiles.append(profile)
                ChatUIKitContext.shared?.groupCache?[groupId] = profile
            }

        }
        return resultProfiles
    }
}
//MARK: - ConversationEmergencyListener
extension  MainViewController: ConversationEmergencyListener {
    func onResult(error: EaseChatUIKit.ChatError?, type: EaseChatUIKit.ConversationEmergencyType) {
        //show toast or alert,then process
    }
    
    func onConversationLastMessageUpdate(message: EaseChatUIKit.ChatMessage, info: EaseChatUIKit.ConversationInfo) {
        //Latest message updated on the conversation.
    }
    
    func onConversationsUnreadCountUpdate(unreadCount: UInt) {
        DispatchQueue.main.async {
            self.chats.tabBarItem.badgeValue = unreadCount > 0 ? "\(unreadCount)" : nil
        }
    }

}

//MARK: - ContactEmergencyListener ContactEventListener
extension MainViewController: ContactEmergencyListener {
    func onResult(error: EaseChatUIKit.ChatError?, type: EaseChatUIKit.ContactEmergencyType, operatorId: String) {
        if type != .setRemark {
            if type == .cleanFriendBadge {
                DispatchQueue.main.async {
                    self.contacts.tabBarItem.badgeValue = nil
                }
            } else {
                self.updateContactBadge()
            }
        }
    }
    
    private func updateContactBadge() {
        if let newFriends = UserDefaults.standard.value(forKey: "EaseChatUIKit_contact_new_request") as? Dictionary<String,Array<Dictionary<String,Any>>> {
            
            let unreadCount = newFriends[saveIdentifier]?.filter({ $0["read"] as? Int == 0 }).count ?? 0
            DispatchQueue.main.async {
                self.contacts.tabBarItem.badgeValue = unreadCount > 0 ? "\(unreadCount)":nil
            }
        } else {
            DispatchQueue.main.async {
                self.contacts.tabBarItem.badgeValue = nil
            }
        }
    }
}

//MARK: - EaseCallDelegate
extension MainViewController: CallServiceListener {
    
    func didOccurError(error: CallError) {
        DispatchQueue.main.async {
            self.showToast(toast: "Occur error:\(error.errorMessage) on module:\(error.module.rawValue)")
        }
        switch error {
        case .im(.invalidURL):
            print("Invalid URL")
        case .rtc(.invalidToken):
            print("Invalid Token")
        case .business(.state):
            print("State error")
        case .business(.param):
            print("Param error")
        default:
            // 注意这里要通过 error.error.message 访问
            print("Other error: \(error.error.message)")
        }
//        switch error.module {//OC use case
//        case .im:
//            switch error.getIMError() {
//            case .invalidURL:
//                print("")
//            default:
//                break
//            }
//        case .rtc:
//            switch error.getRTCError() {
//            case .invalidToken:
//                print("")
//            default:
//                break
//            }
//        case .business:
//            switch error.getCallBusinessError() {
//            case .state:
//                print("")
//            case .param:
//                print("")
//            case .signaling:
//                print("")
//            default:
//                break
//            }
//        default:
//            break
//        }
    }
        
    func didUpdateCallEndReason(reason: CallEndReason, info: CallInfo) {
        print("didUpdateCallEndReason: \(String(describing: info.inviteMessageId))")
        NotificationCenter.default.post(name: Notification.Name("didUpdateCallEndReason"), object: info.inviteMessageId)
        
    }
    
    func remoteUserDidJoined(userId: String, uid: UInt, channelName: String, type: CallType) {
        
    }
    
    func remoteUserDidLeft(userId: String, uid: UInt, channelName: String, type: CallType) {
        
    }
    
    func onReceivedCall(callType: CallType, userId: String, extensionInfo: [String : Any]?) {
        if let controller = UIViewController.currentController,(controller is DialogContainerViewController || controller is AlertViewController || controller is PageContainersDialogController) || controller is ContactViewController {
            //正在通话中或者呼叫中  dismiss跳出来的模态弹窗
            controller.dismiss(animated: false)
            AudioTools.shared.stopRecording()
            AudioTools.shared.stopPlaying()
            return
        }
        self.dismissPickerControllers()
    }
    
    func onRtcEngineCreated(engine: AgoraRtcEngineKit) {
        if let config = UserDefaults.standard.dictionary(forKey: "EaseChatDemoServerConfig") as? [String:String],let ipList = config["rtc_server_ip"],let verifyDomainName = config["rtc_server_domain"] {
            let config = AgoraLocalAccessPointConfiguration()
            config.ipList = [ipList]
            config.verifyDomainName = verifyDomainName
            config.mode = .localOnly
            engine.setLocalAccessPoint(withConfig: config)
        }
    }
    
    func dismissPickerControllers() {
        // 获取当前最顶层的视图控制器
        if let topController = getTopViewController() {
            // 检查是否是指定类型的控制器
            if topController is UIImagePickerController ||
                topController is UIDocumentPickerViewController || topController is PHPickerViewController {
                topController.dismiss(animated: true, completion: nil)
            }
        }
    }

    // 获取最顶层视图控制器的辅助方法
    func getTopViewController() -> UIViewController? {
        // 获取 key window
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        var topController = window.rootViewController
        
        // 遍历 presented 视图控制器链
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
    }
    
}

extension MainViewController: CallUserProfileProvider {
    func fetchGroupProfiles(profileIds: [String]) async -> [any EaseCallUIKit.CallProfileProtocol] {
        consoleLogInfo("fetchGroupProfiles", type: .error)
        return await withTaskGroup(of: [EaseCallUIKit.CallProfileProtocol].self, returning: [EaseCallUIKit.CallProfileProtocol].self) { group in
            var resultProfiles: [EaseCallUIKit.CallProfileProtocol] = []
            group.addTask {
                var resultProfiles: [EaseCallUIKit.CallProfileProtocol] = []
                let result = await self.requestGroupsInfo(groupIds: profileIds)
                if let infos = result {
                    for groupInfo in infos {
                        let profile = EaseCallUIKit.CallUserProfile()
                        profile.id = groupInfo.id
                        profile.nickname = groupInfo.nickname
                        profile.avatarURL = groupInfo.avatarURL
                        resultProfiles.append(profile)
                    }
                }
                return resultProfiles
            }
            //Await all task were executed.Return values.
            for await result in group {
                resultProfiles.append(contentsOf: result)
            }
            return resultProfiles
        }
    }
    
    func fetchUserProfiles(profileIds: [String]) async -> [any EaseCallUIKit.CallProfileProtocol] {
        return await withTaskGroup(of: [EaseCallUIKit.CallProfileProtocol].self, returning: [EaseCallUIKit.CallProfileProtocol].self) { group in
            var resultProfiles: [EaseCallUIKit.CallProfileProtocol] = []
            group.addTask {
                var resultProfiles: [EaseCallUIKit.CallProfileProtocol] = []
                let result = await self.requestUserInfos(profileIds: profileIds) ?? []
                for userInfo in result {
                    let profile = EaseCallUIKit.CallUserProfile()
                    profile.id = userInfo.id
                    profile.nickname = userInfo.nickname.isEmpty ? profile.id:userInfo.nickname
                    profile.avatarURL = userInfo.avatarURL
                    resultProfiles.append(profile)
                }
                return resultProfiles
            }
            //Await all task were executed.Return values.
            for await result in group {
                resultProfiles.append(contentsOf: result)
            }
            return resultProfiles
        }
    }
    
    
}
