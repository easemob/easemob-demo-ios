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

let userAvatarUpdated = "userAvatarUpdated"

final class PersonalInfoViewController: UIViewController {
    
    @UserDefault("EasemobUser",defaultValue: Dictionary<String,Dictionary<String,Dictionary<String,Any>>>()) private var userData
    
    private lazy var infos: [Dictionary<String,String>] = {
        var userId = EaseChatUIKitContext.shared?.currentUserId ?? ""
        if let nickname = EaseChatUIKitContext.shared?.currentUser?.nickname {
            userId = nickname
        }
        return [["title":"Avatar".localized(),"detail":EaseChatUIKitContext.shared?.currentUser?.avatarURL ?? ""],["title":"Nickname".localized(),"detail":userId]]
    }()
    
    private lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(textAlignment: .left)
    }()
    
    private lazy var infoList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), style: .plain).separatorStyle(.none).tableFooterView(UIView()).backgroundColor(.clear).delegate(self).dataSource(self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.navigation,self.infoList])
        self.infoList.reloadData()
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
            default:
                break
            }
        }
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
        imagePicker.videoMaximumDuration = 20
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
            if let imageURL = info[.imageURL] as? URL {
//                let fileName = imageURL.lastPathComponent
                if let image = UIImage(contentsOfFile: imageURL.path) {
                    self.uploadImage(image: image)
                }
                
            } else {
                guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
                self.uploadImage(image: image)
            }
        }
    }
    
    private func uploadImage(image: UIImage) {
        EasemobRequest.shared.uploadImage(image: image) { [weak self] error, result in
            DispatchQueue.main.async {
                if error == nil,let avatarURL = result?["avatarUrl"] as? String {
                    let userId = EaseChatUIKitContext.shared?.currentUserId ?? ""
                    EaseChatUIKitContext.shared?.currentUser?.avatarURL = avatarURL
                    EaseChatUIKitContext.shared?.chatCache?[userId]?.avatarURL = avatarURL
                    self?.infos[0]["detail"] = avatarURL
                    self?.userData[userId]?[userId] = EaseChatUIKitContext.shared?.currentUser?.toJsonObject() ?? [:]
                    self?.infoList.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name(userAvatarUpdated), object: nil)
                } else {
                    self?.showToast(toast: error?.localizedDescription ?? "")
                }
            }
        }
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
