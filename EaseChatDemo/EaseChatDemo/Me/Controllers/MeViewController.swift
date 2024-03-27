//
//  MeViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/5.
//

import UIKit
import EaseChatUIKit
import SwiftFFDB

final class MeViewController: UIViewController {
    
    private let menusData = [
        ["sectionTitle":"Setting".localized(),"sectionData":[["title":"Personal info".localized(),"icon":"userinfo"],["title":"General".localized(),"icon":"general"],["title":"Notification".localized(),"icon":"notification"],["title":"About".localized(),"icon":"about"]]],
        ["sectionTitle":"Login".localized(),"sectionData":[["title":"Logout".localized()]]]
    ]
    
    private lazy var header: DetailInfoHeader = {
        DetailInfoHeader(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 300-NavigationHeight), showMenu: false, placeHolder: Appearance.conversation.singlePlaceHolder)
    }()
    
    private lazy var menuList: UITableView = {
        UITableView(frame: self.view.bounds, style: .plain).backgroundColor(.clear).separatorStyle(.none).tableFooterView(UIView()).tableHeaderView(self.header).dataSource(self).delegate(self).rowHeight(54)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(self.menuList)
        let userId = EaseChatUIKitContext.shared?.currentUserId ?? ""
        var nickName = EaseChatUIKitContext.shared?.currentUser?.nickname ?? ""
        if nickName.isEmpty {
            nickName = userId
        }
        self.fetchUserInfo(userId: userId)
        self.header.status.isHidden = true
        self.header.nickName.text = nickName
        self.header.detailText = userId
        self.header.avatarURL = EaseChatUIKitContext.shared?.currentUser?.avatarURL ?? ""
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshProfile), name: NSNotification.Name(rawValue: userAvatarUpdated), object: nil)
    }
    
    private func fetchUserInfo(userId: String) {
        ChatClient.shared().userInfoManager?.fetchUserInfo(byId: [userId], type: [0,1], completion: { [weak self] infoMap, error in
            if let info = infoMap?[userId],error == nil {
                DispatchQueue.main.async {
                    self?.header.nickName.text = info.nickname
                    self?.header.detailText = userId
                    self?.header.avatarURL = info.avatarUrl
                }
                if let profiles = EaseChatProfile.select(where: "id = ?",values: [userId]) as? [EaseChatProfile],let profile = profiles.first(where: { $0.id == userId }) {
                    profile.nickname = info.nickname ?? userId
                    profile.avatarURL = info.avatarUrl ?? ""
                    profile.updateFFDB()
                    EaseChatUIKitContext.shared?.currentUser = profile
                    EaseChatUIKitContext.shared?.userCache?[profile.id] = profile
                }
            } else {
                self?.showToast(toast: "fetchUserInfo error:\(error?.errorDescription ?? "")")
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        let userId = EaseChatUIKitContext.shared?.currentUserId ?? ""
        var nickName = EaseChatUIKitContext.shared?.currentUser?.nickname ?? ""
        if nickName.isEmpty {
            nickName = userId
        }
        if self.header.nickName.text != nickName,!nickName.isEmpty {
            self.header.nickName.text = nickName
        }
        if let url = EaseChatUIKitContext.shared?.currentUser?.avatarURL,!url.isEmpty  {
            self.header.avatarURL = url
        }
        
    }
    
    @objc private func refreshProfile() {
        self.header.avatarURL = EaseChatUIKitContext.shared?.currentUser?.avatarURL
    }

}

extension MeViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.menusData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (self.menusData[safe:section]?["sectionData"] as? Array<Dictionary<String,Any>>)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        26
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView {
            UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 26))
            UILabel(frame: CGRect(x: 16, y: 4, width: ScreenWidth-32, height: 18)).font(UIFont.theme.labelMedium).textColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor6).text(self.menusData[section]["sectionTitle"] as? String ?? "").backgroundColor(.clear)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MeMenuCell") as? MeMenuCell
        if cell == nil {
            cell = MeMenuCell(style: .default, reuseIdentifier: "MeMenuCell")
        }
        
        if let rowDatas = self.menusData[safe:indexPath.section]?["sectionData"] as? Array<Dictionary<String,String>> {
            let title = rowDatas[safe:indexPath.row]?["title"] as? String
            let imageName = rowDatas[safe:indexPath.row]?["icon"] ?? ""
            cell?.icon.image = UIImage(named: imageName)
            if let rowTitle = title,rowTitle == "Logout".localized() {
                cell?.textLabel?.text = title
                cell?.textLabel?.isHidden = false
                cell?.icon.isHidden = true
                cell?.content.isHidden = true
                cell?.detail.isHidden = true
            } else {
                cell?.content.text = title
                cell?.icon.isHidden = false
                cell?.textLabel?.isHidden = true
                cell?.content.isHidden = false
                cell?.detail.isHidden = false
                cell?.selectionStyle = .none
                cell?.accessoryType = .disclosureIndicator
                cell?.content.textColor = Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
            }
        }
        
        return cell ?? MeMenuCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let rowDatas = self.menusData[safe:indexPath.section]?["sectionData"] as? Array<Dictionary<String,String>>,let title = rowDatas[safe:indexPath.row]?["title"] as? String {
            switch title {
            case "Personal info".localized(): self.viewProfile()
            case "General".localized(): self.viewGeneral()
            case "Notification".localized(): self.viewNotification()
            case "About".localized(): self.viewAbout()
            case "Logout".localized(): self.logout()
            default:
                break
            }
        }
    }
    
    private func viewProfile() {
        let vc = PersonalInfoViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func viewGeneral() {
        let vc = GeneralViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func viewNotification() {
        let vc = NotificationSettingViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func viewAbout() {
        let vc = AboutEasemobController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func logout() {
        DialogManager.shared.showAlert(title: "Confirm Logout".localized(), content: "", showCancel: true, showConfirm: true) { _ in
            EaseChatUIKitClient.shared.logout(unbindNotificationDeviceToken: true) { error in
                if error == nil {
                    NotificationCenter.default.post(name: Notification.Name(backLoginPage), object: nil, userInfo: nil)
                } else {
                    self.showToast(toast: "\(error?.errorDescription ?? "")")
                }
            }
        }
    }
}


extension MeViewController: ThemeSwitchProtocol {
    
    func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.menuList.reloadData()
    }
}

extension FFObject {
    @discardableResult
    public func updateFFDB() -> Bool {
        do {
            var values = [Any]()
            for column in subType.columnsOfSelf() {
                let value = valueNotNullFrom(column)
                values.append(value)
            }
            values.append(valueNotNullFrom("id"))
//            values.append(valueNotNullFrom(subType.primaryKeyColumn()))
            return try FFDBManager.update(subType, set: subType.columnsOfSelf(), where: "id = ?",values:values)
        } catch {
            consoleLogInfo("failed: \(error.localizedDescription)", type: .error)
        }
        return false
    }
}
