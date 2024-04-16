//
//  GeneralViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/7.
//

import UIKit
import EaseChatUIKit

final class GeneralViewController: UIViewController {
    
    @UserDefault("EaseChatDemoDarkMode", defaultValue: false) var darkMode: Bool
    
    @UserDefault("EaseChatDemoPreferencesLanguage", defaultValue: "zh-Hans") var language: String
    
    @UserDefault("EaseChatDemoPreferencesTheme", defaultValue: 0) var theme: UInt
    
    private lazy var jsons: [Dictionary<String,Any>] = {
        [["title":"dark_mode".localized(),"detail":"","withSwitch": true,"switchValue":self.darkMode],["title":"switch_theme".localized(),"detail":(self.theme == 0 ? "Classic".localized():"Smart".localized()),"withSwitch": false,"switchValue":false],["title":"color_setting".localized(),"detail":"","withSwitch": false,"switchValue":false],["title":"feature_switch".localized(),"detail":"","withSwitch": false,"switchValue":false],["title":"language_setting".localized(),"detail":self.language.hasPrefix("zh") ? "Chinese".localized():"English".localized(),"withSwitch": false,"switchValue":false]]
    }()
    
    private lazy var datas: [DetailInfo] = {
        self.jsons.map {
            let info = DetailInfo()
            info.setValuesForKeys($0)
            return info
        }
    }()
    
    private lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: NavigationHeight), textAlignment: .left, rightTitle: nil)
    }()
    
    private lazy var menuList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(54).backgroundColor(.clear)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubViews([self.navigation,self.menuList])
        self.navigation.title = "General".localized()
        self.navigation.clickClosure = { [weak self] _,_ in
            self?.navigationController?.popViewController(animated: true)
        }
        // Do any additional setup after loading the view.
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    

}

extension GeneralViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.jsons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "GeneralCell") as? DetailInfoListCell
        if cell == nil {
            cell = DetailInfoListCell(style: .default, reuseIdentifier: "GeneralCell")
        }
        cell?.indexPath = indexPath
        if let info = self.datas[safe: indexPath.row] {
            cell?.accessoryType = info.withSwitch ? .none:.disclosureIndicator
            cell?.refresh(info: info)
        }
        cell?.valueChanged = { [weak self] in
            self?.switchChanged(isOn: $0, indexPath: $1)
        }
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    func switchChanged(isOn: Bool, indexPath: IndexPath) {
        Theme.switchTheme(style: isOn ? .dark:.light)
        self.darkMode = isOn
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let title = self.datas[safe: indexPath.row]?.title,title != "dark_mode".localized() {
            switch title {
            case "switch_theme".localized(): self.switchTheme()
            case "color_setting".localized(): self.colorSet()
            case "feature_switch".localized(): self.featureSwitch()
            case "language_setting".localized(): self.languageSet()
            default:
                break
            }
        }
    }
    
    private func switchTheme() {
        let vc = ThemesSettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func colorSet() {
        let vc = ColorSettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func featureSwitch() {
        let vc = FeatureSwitchViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func languageSet() {
        let vc = LanguageSettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension GeneralViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
}
