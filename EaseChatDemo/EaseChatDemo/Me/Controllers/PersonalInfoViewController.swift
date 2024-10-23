//
//  PersonalInfoViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/6.
//

import UIKit
import EaseChatUIKit
import MobileCoreServices
import AVFoundation
import SwiftFFDBHotFix

let userAvatarUpdated = "userAvatarUpdated"

final class PersonalInfoViewController: UIViewController {
    
    private lazy var infos: [Dictionary<String,String>] = {
        var userId = ChatUIKitContext.shared?.currentUserId ?? ""
        if let nickname = ChatUIKitContext.shared?.currentUser?.nickname {
            userId = nickname
        }
        return [["title":"Avatar".localized(),"detail":ChatUIKitContext.shared?.currentUser?.avatarURL ?? ""],["title":"Nickname".localized(),"detail":userId]]
    }()
    
    private lazy var navigation: ChatNavigationBar = {
        ChatNavigationBar(textAlignment: .left)
    }()
    
    private lazy var infoList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), style: .plain).separatorStyle(.none).tableFooterView(UIView()).backgroundColor(.clear).delegate(self).dataSource(self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.navigation,self.infoList])
        self.infoList.reloadData()
        if let url = ChatUIKitContext.shared?.currentUser?.avatarURL,!url.isEmpty {
            self.navigation.avatarURL = url
        }
        
        self.navigation.title = "Personal Info".localized()
        self.navigation.clickClosure = { [weak self] _,_ in
            self?.navigationController?.popViewController(animated: true)
        }
        // Do any additional setup after loading the view.
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    

    

}

extension PersonalInfoViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        54
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.infos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PersonalInfoCell") as? PersonalInfoCell
        if cell == nil {
            cell = PersonalInfoCell(style: .default, reuseIdentifier: "PersonalInfoCell")
        }
        if let title = self.infos[safe:indexPath.row]?["title"] as? String, let detail = self.infos[safe:indexPath.row]?["detail"] as? String {
            cell?.refresh(title: title, detail: detail)
        }
        
        cell?.accessoryType = .disclosureIndicator
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let title = self.infos[safe:indexPath.row]?["title"] as? String {
            switch title {
            case "Avatar".localized():
                DialogManager.shared.showActions(actions: [ActionSheetItem(title: "input_extension_menu_photo".chat.localize, type: .normal,tag: "Photo",image: UIImage(named: "photo", in: .chatBundle, with: nil)), ActionSheetItem(title: "input_extension_menu_camera".chat.localize, type: .normal,tag: "Camera",image: UIImage(named: "camera_fill", in: .chatBundle, with: nil))]) { [weak self] item in
                    self?.processAction(item: item)
                }
            case "Nickname".localized(): self.editName()
            default:
                break
            }
        }
    }
    
    private func editName() {
        guard let userId = ChatUIKitContext.shared?.currentUserId else { return }
        let vc = MineContactRemarkEditViewController(userId: userId, rawText: self.infos[1]["detail"] ?? "") { [weak self] nickname in
            guard let `self` = self else { return }
            self.updateUserInfo(userId: userId, nickname: nickname)
        }
        vc.navigation.title = "Modify Nickname".localized()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateUserInfo(userId: String,nickname: String) {
        ChatClient.shared().userInfoManager?.updateOwnUserInfo(nickname, with: .nickName, completion: { [weak self] info, error in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if error == nil {
                    self.infos[1]["detail"] = nickname
                    self.infoList.reloadData()
                    ChatUIKitContext.shared?.currentUser?.nickname = nickname
                    ChatUIKitContext.shared?.userCache?[userId]?.nickname = nickname
                    ChatUIKitContext.shared?.chatCache?[userId]?.nickname = nickname
                    if let userJson = ChatUIKitContext.shared?.currentUser?.toJsonObject() {
                        let profile = EaseChatProfile()
                        profile.setValuesForKeys(userJson)
                        profile.updateFFDB()
                    }
                } else {
                    DialogManager.shared.showAlert(title: "error".chat.localize, content: "update nickname failed".chat.localize, showCancel: false, showConfirm: true) { _ in
                        
                    }
                }
            }
        })
    }
    
    @objc private func processAction(item: ActionSheetItemProtocol) {
        switch item.tag {
        case "Photo": self.selectPhoto()
        case "Camera": self.openCamera()
        default:
            break
        }
    }
    
    /**
     Opens the photo library and allows the user to select a photo.
     
     - Note: This method checks if the photo library is available on the device. If it is not available, an alert is displayed to the user.
     */
    @objc private func selectPhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            DialogManager.shared.showAlert(title: "permissions disable".chat.localize, content: "photo_disable".chat.localize, showCancel: false, showConfirm: true) { _ in
                
            }
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            DialogManager.shared.showAlert(title: "permissions disable".chat.localize, content: "camera_disable".chat.localize, showCancel: false, showConfirm: true) { _ in
                
            }
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [kUTTypeImage as String]
        self.present(imagePicker, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerControllerDelegate&UINavigationControllerDelegate
extension PersonalInfoViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.processImagePickerData(info: info)
        picker.dismiss(animated: true, completion: nil)
    }
    
    /**
     Processes the data received from the image picker.
     
     - Parameters:
         - info: A dictionary containing the information about the selected media.
     */
    @objc private func processImagePickerData(info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String
        if mediaType == kUTTypeImage as String {
            if let image = info[.editedImage] as? UIImage {
                self.uploadImage(image: image.fixOrientation())
            }
        }
    }
    
    private func uploadImage(image: UIImage) {
        EasemobRequest.shared.uploadImage(image: image) { [weak self] error, result in
            DispatchQueue.main.async {
                if error == nil,let avatarURL = result?["avatarUrl"] as? String {
                    let userId = ChatUIKitContext.shared?.currentUserId ?? ""
                    ChatUIKitContext.shared?.currentUser?.avatarURL = avatarURL
                    ChatUIKitContext.shared?.chatCache?[userId]?.avatarURL = avatarURL
                    self?.infos[0]["detail"] = avatarURL
                    if let userJson = ChatUIKitContext.shared?.currentUser?.toJsonObject() {
                        let profile = EaseChatProfile()
                        profile.setValuesForKeys(userJson)
                        profile.updateFFDB()
                    }
                    self?.setUserAvatar(url: avatarURL)
                    self?.infoList.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name(userAvatarUpdated), object: nil)
                } else {
                    self?.showToast(toast: error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    private func setUserAvatar(url: String) {
        ChatClient.shared().userInfoManager?.updateOwnUserInfo(url, with: .avatarURL, completion: { info, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.showToast(toast: "\(error?.errorDescription ?? "update avatar failed")" )
                }
            }
        })
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PersonalInfoViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.infoList.reloadData()
    }
}


extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        var transform: CGAffineTransform = .identity
          
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi / 2)
        case .up, .upMirrored:
            break
        @unknown default:
            fatalError()
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            fatalError()
        }
        
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0, space: cgImage!.colorSpace!, bitmapInfo: cgImage!.bitmapInfo.rawValue)!
        context.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        let cgImage: CGImage = context.makeImage()!
        return UIImage(cgImage: cgImage)
    }
}
