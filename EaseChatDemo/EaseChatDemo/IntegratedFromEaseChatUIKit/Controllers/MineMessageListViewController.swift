//
//  MineMessageListViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/14.
//

import UIKit
import EaseChatUIKit
import EaseCallUIKit
import Photos
import AVFoundation

let callIdentifier = "msgType"

let callValue = "rtcCallWithAgora"

final class MineMessageListViewController: MessageListController {
    
    private var otherPartyStatus = ""
    
    private var imageEntity = EaseChatUIKit.MessageEntity()
        
    lazy var fraudView: FraudAlertView = {
        FraudAlertView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: EaseChatUIKit.ScreenWidth <= 375 ? 84:72))
    }()
    
    override func createMessageContainer() -> MessageListView {
        MessageListView(frame: CGRect(x: 0, y: self.fraudView.frame.maxY, width: self.view.frame.width, height: EaseChatUIKit.ScreenHeight-self.fraudView.frame.maxY), mention: self.chatType == .group)
    }
    
    private var audioRecordView: MessageAudioRecordView?

    override func viewDidLoad() {
        self.view.addSubview(self.fraudView)
        super.viewDidLoad()
        let alertView = UIImageView(frame: self.messageContainer.bounds).contentMode(.scaleAspectFit).tag(55)
        let alertImage = UIImage(named: "zhapian")?.withTintColor(EaseChatUIKit.Theme.style == .dark ? UIColor.theme.neutralColor7:UIColor.theme.neutralColor5)
        alertView.image =  alertImage
        self.messageContainer.insertSubview(alertView, at: 0)
        self.fraudView.closeClosure = { [weak self] in
            guard let `self` = self else { return }
            UIView.animate(withDuration: 0.22) {
                self.messageContainer.frame = CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: EaseChatUIKit.ScreenHeight-self.navigation.frame.maxY)
            }
        }
        self.fraudView.fraudContent.clickAction = { [weak self] in
            self?.showToast(toast: "感谢您的举报，我们将尽快处理")
        }
        // Do any additional setup after loading the view.
        if self.chatType == .chat {
            self.subscribeUserStatus()
        }
        self.navigation.status.isHidden = self.chatType != .chat
        NotificationCenter.default.addObserver(forName: Notification.Name("didUpdateCallEndReason"), object: nil, queue: .main) { [weak self] notification in
            guard let `self` = self, let messageId = notification.object as? String else { return }
            if let message = self.messageContainer.messages.first(where: { $0.message.messageId == messageId }) {
                message.setValue(message.convertTextAttribute(), forKey: "content")
                self.messageContainer.reloadCallMessage(message: message.message)
            }
            
        }
    }
    
    
    deinit {
        PresenceManager.shared.unsubscribe(members: [self.profile.id], completion: nil)
        ChatUIKitContext.shared?.cleanCache(type: .chat)
        URLPreviewManager.caches.removeAll()
    }
    
    @objc func subscribeUserStatus() {
        PresenceManager.shared.addHandler(handler: self)
        PresenceManager.shared.subscribe(members: [self.profile.id]) { [weak self] presences, error in
            if let presence = presences?.first {
                self?.showUserStatus(state: PresenceManager.status(with: presence))
            }
        }
    }
    
    override func performTypingTask() {
        if self.chatType == .chat {
            DispatchQueue.main.async {
                self.navigation.subtitle = self.otherPartyStatus
                self.navigation.title = self.navigation.title
            }
        }
    }
    
    private func showUserStatus(state: PresenceManager.State) {
        let subtitle = PresenceManager.showStatusMap[state] ?? ""
        switch state {
        case .online:
            self.navigation.userState = .online
        case .offline:
            self.navigation.userState = .offline
        case .busy:
            self.navigation.status.image = nil
            self.navigation.status.backgroundColor = EaseChatUIKit.Theme.style == .dark ? UIColor.theme.errorColor5:UIColor.theme.errorColor6
        case .away:
            self.navigation.status.backgroundColor = EaseChatUIKit.Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
            self.navigation.status.image(PresenceManager.presenceImagesMap[.away] as? UIImage)
        case .doNotDisturb:
            self.navigation.status.backgroundColor = EaseChatUIKit.Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
            self.navigation.status.image(PresenceManager.presenceImagesMap[.doNotDisturb] as? UIImage)
        case .custom:
            self.navigation.status.backgroundColor = EaseChatUIKit.Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
            self.navigation.status.image(PresenceManager.presenceImagesMap[.custom] as? UIImage)
        }
        self.otherPartyStatus = subtitle
        self.navigation.subtitle = subtitle
        self.navigation.title = self.navigation.title

    }
    
    /**
     Updates the user state and sets it to the specified state.
     
     - Parameters:
        - state: The new user state.
     */
    @MainActor @objc public func updateUserState(state: UserState) {
        self.navigation.userState = state
    }
    
    override func rightImages() -> [UIImage] {
        var images = [UIImage(named: "pinned_messages", in: .chatBundle, with: nil)!,UIImage(named: "message_action_topic", in: .chatBundle, with: nil)!,UIImage(named: "call", in: .chatBundle, with: nil)!]
        if self.chatType == .chat {
            images = [UIImage(named: "pinned_messages", in: .chatBundle, with: nil)!,UIImage(named: "call", in: .chatBundle, with: nil)!]
        } else {
            if !Appearance.chat.contentStyle.contains(.withMessageThread) {
                if images.count > 0 {
                    images.remove(at: 0)
                }
            }
        }
        return images
    }
    
    override func rightItemsAction(indexPath: IndexPath?) {
        guard let idx = indexPath else { return }
        switch idx.row {
        case 0: self.showPinnedMessages()
        case 1:
            if self.chatType == .group {
                !Appearance.chat.contentStyle.contains(.withMessageThread) ? self.callAction():self.viewTopicList()
            } else {
                self.callAction()
            }
        case 2: self.callAction()
        default:
            break
        }
    }
    
    
    private func callAction() {
        if self.chatType == .group {
            self.startGroupCall()
        } else {
            DialogManager.shared.showActions(actions: [ActionSheetItem(title: "Audio Call".localized(), type: .normal, tag: "AudioCall"),ActionSheetItem(title: "Video Call".localized(), type: .normal, tag: "VideoCall")]) { [weak self] item in
                self?.processItemAction(item: item)
            }
        }
    }
    
    private func processItemAction(item: ActionSheetItemProtocol) {
        var callType = CallType.singleAudio
        if item.tag == "VideoCall".localized() {
            callType = .singleVideo
        }
        
        if self.chatType == .chat {
            self.startSingleCall(callType: callType)
        }
    }
    
    private func startSingleCall(callType: CallType) {
        // Check permissions based on call type
        self.checkPermissionsAndCall(callType: callType) { [weak self] granted in
            guard granted, let self = self else { return }

            if let cacheUser = ChatUIKitContext.shared?.userCache?[self.profile.id] {
                let callProfile = CallUserProfile()
                callProfile.id = cacheUser.id
                callProfile.nickname = cacheUser.nickname
                callProfile.avatarURL = cacheUser.avatarURL
                CallKitManager.shared.usersCache[self.profile.id] = callProfile
            }
            if let currentUser = ChatUIKitContext.shared?.currentUser {
                let callProfile = CallUserProfile()
                callProfile.id = ChatClient.shared().currentUsername ?? ""
                callProfile.nickname = currentUser.nickname
                callProfile.avatarURL = currentUser.avatarURL
                CallKitManager.shared.currentUserInfo = callProfile
                CallKitManager.shared.usersCache[callProfile.id] = callProfile
                consoleLogInfo("startSingleCall current user:\(callProfile.nickname)", type: .info)
            }
            CallKitManager.shared.call(with: self.profile.id, type: callType)
        }
    }

    private func startGroupCall() {
        // Group call requires both audio and video permissions
        self.checkPermissionsAndCall(callType: .groupCall) { [weak self] granted in
            guard granted, let self = self else { return }

            if let cacheUser = ChatUIKitContext.shared?.groupCache?[self.profile.id] {
                let callProfile = CallUserProfile()
                callProfile.id = cacheUser.id
                callProfile.nickname = cacheUser.nickname
                callProfile.avatarURL = cacheUser.avatarURL
                CallKitManager.shared.usersCache[self.profile.id] = callProfile
            }
            if let currentUser = ChatUIKitContext.shared?.currentUser {
                let callProfile = CallUserProfile()
                callProfile.id = ChatClient.shared().currentUsername ?? ""
                callProfile.nickname = currentUser.nickname
                callProfile.avatarURL = currentUser.avatarURL
                CallKitManager.shared.currentUserInfo = callProfile
                CallKitManager.shared.usersCache[callProfile.id] = callProfile
                consoleLogInfo("startGroupCall current user:\(callProfile.nickname)", type: .info)
            }
            CallKitManager.shared.groupCall(groupId: self.profile.id)
        }
    }

    /// Check audio/video permissions based on call type
    private func checkPermissionsAndCall(callType: CallType, completion: @escaping (Bool) -> Void) {
        switch callType {
        case .singleAudio:
            // Audio call only requires microphone permission
            self.checkMicrophonePermission { granted in
                if !granted {
                    DispatchQueue.main.async {
                        self.showPermissionAlert(message: "Audio call requires microphone permission. Please enable it in Settings.".localized())
                    }
                }
                completion(granted)
            }
        case .singleVideo, .groupCall:
            // Video call requires both microphone and camera permissions
            self.checkMicrophonePermission { [weak self] micGranted in
                guard let self = self else {
                    completion(false)
                    return
                }
                if !micGranted {
                    DispatchQueue.main.async {
                        self.showPermissionAlert(message: "Video call requires microphone permission. Please enable it in Settings.".localized())
                    }
                    completion(false)
                    return
                }
                self.checkCameraPermission { camGranted in
                    if !camGranted {
                        DispatchQueue.main.async {
                            self.showPermissionAlert(message: "Video call requires camera permission. Please enable it in Settings.".localized())
                        }
                    }
                    completion(camGranted)
                }
            }
        default:
            completion(false)
        }
    }

    private func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }

    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }

    private func showPermissionAlert(message: String) {
        DialogManager.shared.showAlert(
            title: "Permission Required".localized(),
            content: message,
            showCancel: true,
            showConfirm: true
        ) { _ in
            // Open app settings
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }

    override func filterMessageActions(message: EaseChatUIKit.MessageEntity) -> [EaseChatUIKit.ActionSheetItemProtocol] {
        if let ext = message.message.ext,let value = ext[callIdentifier] as? String,value == callValue {
            return [
                ActionSheetItem(title: "barrage_long_press_menu_delete".chat.localize, type: .normal,tag: "Delete",image: UIImage(named: "message_action_delete", in: .chatBundle, with: nil)),
                ActionSheetItem(title: "barrage_long_press_menu_multi_select".chat.localize, type: .normal,tag: "MultiSelect",image: UIImage(named: "message_action_multi_select", in: .chatBundle, with: nil)),
                ActionSheetItem(title: "barrage_long_press_menu_forward".chat.localize, type: .normal,tag: "Forward",image: UIImage(named: "message_action_forward", in: .chatBundle, with: nil))
            ]
        } else {
            return super.filterMessageActions(message: message)
        }
    }
    
    override func messageBubbleClicked(message: EaseChatUIKit.MessageEntity) {
        switch message.message.body.type {
        case .text:
            if let info = message.message.callInfo {
                if info.type == .groupCall {
                    self.startGroupCall()
                } else {
                    self.startSingleCall(callType: info.type)
                }
            }
        case .image:
            if let body = message.message.body as? ChatImageMessageBody {
                self.filePath = body.localPath
                if body.isGif {
                    self.openFile()
                } else {
                    self.viewImage(entity: message)
                }
            }
        case .file,.video:
            if let body = message.message.body as? ChatFileMessageBody {
                self.filePath = body.localPath ?? ""
            }
            self.openFile()
        case .custom:
            if let body = message.message.body as? ChatCustomMessageBody,body.event == EaseChatUIKit_user_card_message {
                self.viewContact(body: body)
            }
            if let body = message.message.body as? ChatCustomMessageBody,body.event == EaseChatUIKit_alert_message {
                self.viewAlertDetail(message: message.message)
            }
            if let body = message.message.body as? ChatCustomMessageBody,body.event == EaseChatUIKit_alert_message {
                let threadId = message.message.alertMessageThreadId
                if let messageId = message.message.ext?["messageId"] as? String,let message = ChatClient.shared().chatManager?.getMessageWithMessageId(messageId) {
                    self.enterTopic(threadId: threadId, message: message)
                }
            }
        case .combine:
            self.viewHistoryMessages(entity: message)
        default:
            break
        }
    }
    
    func viewImage(entity: EaseChatUIKit.MessageEntity) {
        self.imageEntity = entity
        let preview = ImagePreviewController(with: self)
        preview.selectedIndex = 0
        preview.presentDuration = 0.3
        preview.dissmissDuration = 0.3
        self.present(preview, animated: true)
        
    }
    
}

extension MineMessageListViewController: ImageBrowserProtocol {
    func numberOfPhotos(with browser: ImagePreviewController) -> Int {
        1
    }
    
    func photo(of index: Int, with browser: ImagePreviewController) -> PreviewImage {
        if let row = self.messageContainer.messages.firstIndex(of: self.imageEntity),let cell = self.messageContainer.messageList.cellForRow(at: IndexPath(item: row, section: 0)) as? ImageMessageCell,let image = cell.content.image {
            return PreviewImage(image: image, originalView: cell.content)
        }
        return PreviewImage(image: UIImage())
    }
    
    func didLongPressPhoto(at index: Int, with browser: ImagePreviewController) {
        DialogManager.shared.showActions(actions: [ActionSheetItem(title: "Save Image".localized(), type: .normal, tag: "SaveImage",image: UIImage(named: "photo", in: .chatBundle, with: nil)),ActionSheetItem(title: "barrage_long_press_menu_forward".chat.localize, type: .normal,tag: "Forward",image: UIImage(named: "message_action_forward", in: .chatBundle, with: nil))]) { [weak self] item in
            guard let `self` = self else {return}
            switch item.tag {
            case "SaveImage": self.saveImageToAlbum()
            case "Forward": self.forwardMessage(message: self.imageEntity.message)
            default:break
            }
        }
    }
    
    func saveImageToAlbum() {
        if let row = self.messageContainer.messages.firstIndex(of: self.imageEntity),let cell = self.messageContainer.messageList.cellForRow(at: IndexPath(item: row, section: 0)) as? ImageMessageCell,let image = cell.content.image {
            // Check authorization status
            let status = PHPhotoLibrary.authorizationStatus()
            
            switch status {
            case .authorized,.limited:
                // Save the image if authorized
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            case .denied, .restricted:
                // Handle denied or restricted status
                DialogManager.shared.showAlert(title: "Access Limited", content: "Access to photo library is denied or restricted.", showCancel: true, showConfirm: true) { _ in
                    
                }
            case .notDetermined:
                // Request authorization
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        // Save the image if authorized
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    } else {
                        DialogManager.shared.showAlert(title: "Access Denied", content: "Access to photo library is denied.", showCancel: false, showConfirm: true) { _ in
                            
                        }
                    }
                }
            @unknown default:
                fatalError("Unknown authorization status")
            }
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle the error
            UIViewController.currentController?.showToast(toast: "Failed to save image.")
        } else {
            // Handle success
            UIViewController.currentController?.showToast(toast: "Successful to save image.")
        }
    }
}

extension MineMessageListViewController: PresenceDidChangedListener {
    func presenceStatusChanged(users: [String]) {
        if users.contains(self.profile.id), let presence = PresenceManager.shared.presences[self.profile.id] {
            self.showUserStatus(state: PresenceManager.status(with: presence))
        }
    }
    
    
}
