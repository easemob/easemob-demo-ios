//
//  GeneralViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/7.
//

import UIKit
import EaseChatUIKit
import QuickLook

final class GeneralViewController: UIViewController {
    
    @UserDefault("EaseChatDemoDarkMode", defaultValue: false) var darkMode: Bool
        
    @UserDefault("EaseChatDemoPreferencesTheme", defaultValue: 1) var theme: UInt
    
    @UserDefault("EaseChatDemoPreferencesLanguage", defaultValue: "zh-Hans") var language: String
    
    @UserDefault("EaseChatDemoTranslateTargetLanguage", defaultValue: "zh-Hans") var translate_language: String
    
    @UserDefault("EaseChatDemoPreferencesLongPressStyle", defaultValue: 0) var longPressStyle: UInt8
    
    @UserDefault("EaseChatDemoPreferencesAttachmentStyle", defaultValue: 0) var attachmentStyle: UInt8

    private lazy var jsons: [Dictionary<String,Any>] = {
        [["title":"dark_mode".localized(),"detail":"","withSwitch": true,"switchValue":self.darkMode],
         ["title":"switch_theme".localized(),"detail":(self.theme == 0 ? "Classic".localized():"Smart".localized()),"withSwitch": false,"switchValue":false],
         ["title":"long_press_style".localized(),"detail":self.longPressStyle == 0 ? "style1".localized() : "style2".localized(),"withSwitch": false,"switchValue":false],
         ["title":"attachment_menu_style".localized(),"detail":self.attachmentStyle == 0 ? "style1".localized() : "style2".localized(),"withSwitch": false,"switchValue":false],
         ["title":"color_setting".localized(),"detail":"","withSwitch": false,"switchValue":false],
         ["title":"feature_switch".localized(),"detail":"","withSwitch": false,"switchValue":false],
         ["title":"language_setting".localized(),"detail":self.language.hasPrefix("zh") ? "Chinese".localized():"English".localized(),"withSwitch": false,"switchValue":false],
         ["title":"translate_language_setting".localized(),"detail":self.translate_language.hasPrefix("zh") ? "Chinese".localized():"English".localized(),"withSwitch": false,"switchValue":false],
         ["title":"Debug Log".localized(),"detail":"","withSwitch": false,"switchValue":false],
         ["title":"CallBackground".localized(),"detail":"","withSwitch": false,"switchValue":false]
        ]
    }()
    
    private lazy var datas: [DetailInfo] = {
        self.fillDatas()
    }()
    
    private lazy var navigation: ChatNavigationBar = {
        ChatNavigationBar(show: CGRect(x: 0, y: 0, width: self.view.frame.width, height: NavigationHeight), textAlignment: .left, rightTitle: nil)
    }()
    
    private lazy var menuList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(54).backgroundColor(.clear).separatorStyle(.none)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.datas.first { $0.title == "long_press_style".localized() }?.detail = self.longPressStyle == 0 ? "style1".localized() : "style2".localized()
        self.datas.first { $0.title == "attachment_menu_style".localized() }?.detail = self.attachmentStyle == 0 ? "style1".localized() : "style2".localized()
        self.datas.first { $0.title == "translate_language_setting".localized() }?.detail = self.translate_language.hasPrefix("zh") ? "Chinese".localized():"English".localized()
        self.menuList.reloadData()
    }
    
    private func fillDatas() -> [DetailInfo] {
        self.jsons.map {
            let info = DetailInfo()
            info.setValuesForKeys($0)
            return info
        }
    }
}

extension GeneralViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "GeneralCell") as? DetailInfoListCell
        if cell == nil {
            cell = DetailInfoListCell(style: .default, reuseIdentifier: "GeneralCell")
        }
        cell?.indexPath = indexPath
        if let info = self.datas[safe: indexPath.row] {
            cell?.refresh(info: info)
        }
        cell?.valueChanged = { [weak self] in
            self?.switchChanged(isOn: $0, indexPath: $1)
        }
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    func switchChanged(isOn: Bool, indexPath: IndexPath) {
        if let title = self.datas[safe: indexPath.row]?.title {
            self.datas[safe: indexPath.row]?.switchValue = isOn
            switch title {
            case "dark_mode".localized():
                Theme.switchTheme(style: isOn ? .dark:.light)
                self.darkMode = isOn
            default:
                break
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let title = self.datas[safe: indexPath.row]?.title,title != "dark_mode".localized() {
            switch title {
            case "switch_theme".localized(): self.switchTheme()
            case "color_setting".localized(): self.colorSet()
            case "feature_switch".localized(): self.featureSwitch()
            case "language_setting".localized(): self.languageSet()
            case "Debug Log".localized(): self.openLog()
            case "translate_language_setting".localized(): self.translateLanguageSet()
            case "long_press_style".localized(): self.chooseMenuStyle(style: .longPress)
            case "attachment_menu_style".localized(): self.chooseMenuStyle(style: .attachment)
            case "CallBackground".localized(): self.changeCallBackground()
            default:
                break
            }
        }
    }
    
    private func changeCallBackground() {
        let vc = CallBackgroundSettingController()
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    private func translateLanguageSet() {
        let vc = TranslateLanguageSettingController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openLog() {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        self.present(previewController, animated: true)
    }
    
    private func chooseMenuStyle(style : ShowMenuStyle) {
        let vc = ShowMenuStyleViewController(style: style)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension GeneralViewController: QLPreviewControllerDataSource {
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Application Support/HyphenateSDK/easemobLog/easemob.log")
        return fileURL as QLPreviewItem
    }
    
    
}

extension GeneralViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.menuList.reloadSections(IndexSet(arrayLiteral: 0), with: .none)
    }
}
