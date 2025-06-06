//
//  LanguageSettingViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/7.
//

import UIKit
import EaseChatUIKit

final class LanguageSettingViewController: UIViewController {
    
    @UserDefault("EaseChatDemoPreferencesLanguage", defaultValue: "zh-Hans") var language: String

    private var infos = ["Chinese".localized(),"English".localized()]
    
    private var languageRawValues = ["zh-Hans","en"]
    
    private lazy var navigation: ChatNavigationBar = {
        ChatNavigationBar(show: CGRect(x: 0, y: 0, width: self.view.frame.width, height: NavigationHeight),textAlignment: .left,rightTitle: "Confirm".chat.localize)
    }()
    
    private lazy var infoList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), style: .plain).separatorStyle(.none).tableFooterView(UIView()).backgroundColor(.clear).delegate(self).dataSource(self).rowHeight(54)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubViews([self.navigation,self.infoList])
        self.navigation.title = "language_setting".localized()
        self.navigation.clickClosure = { [weak self] in
            consoleLogInfo("\($1?.row ?? 0)", type: .debug)
            switch $0 {
            case .back:
                self?.navigationController?.popViewController(animated: true)
            case  .rightTitle:
                DialogManager.shared.showAlert(title: "Switch Language".localized(), content: "Switch Language".localized()+"Terminal Alert".localized(), showCancel: true, showConfirm: true) { [weak self] _ in
                    guard let `self` = self else { return }
                    Appearance.ease_chat_language = LanguageType(rawValue: self.language) ?? .Chinese
                    exit(0)
                }
            default:
                break
            }
            
        }
        // Do any additional setup after loading the view.
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }

}

extension LanguageSettingViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.infos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell") as? LanguageCell
        if cell == nil {
            cell = LanguageCell(style: .default, reuseIdentifier: "LanguageCell")
        }
        if let title = self.infos[safe:indexPath.row],let languageCode = self.languageRawValues[safe: indexPath.row] {
            cell?.content.text = title
            if self.language == languageCode {
                cell?.checkbox.isSelected = true
            } else {
                cell?.checkbox.isSelected = false
            }
        }
        cell?.accessoryType = .none
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let code = self.languageRawValues[safe:indexPath.row] {
            self.language = code
        }
        self.infoList.reloadData()
    }
}

extension LanguageSettingViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
    }
}
