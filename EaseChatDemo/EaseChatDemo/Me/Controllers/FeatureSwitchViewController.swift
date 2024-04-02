//
//  FeatureSwitchViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/13.
//

import UIKit
import EaseChatUIKit

final class FeatureSwitchViewController: UIViewController {
    
    @UserDefault("EaseMobChatMessageTargetLanguage", defaultValue: true) var targetLanguage: Bool
    
    @UserDefault("EaseMobChatMessageReaction", defaultValue: true) var messageReaction: Bool
    
    @UserDefault("EaseMobChatCreateTopic", defaultValue: true) var createTopic: Bool
    
    
    private lazy var jsons: [Dictionary<String,Any>] = {
        [["title":"message_translate".localized(),"detail":"message_translate_description".localized(),"withSwitch": true,"switchValue":self.targetLanguage],["title":"group_topic".localized(),"detail":"group_topic_description","withSwitch": true,"switchValue":self.createTopic],["title":"message_reaction".localized(),"detail":"message_reaction_description","withSwitch": true,"switchValue":self.messageReaction]]
    }()

    private lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: NavigationHeight), textAlignment: .left, rightTitle: nil)
    }()
    
    private lazy var featureList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(80).backgroundColor(.clear).separatorStyle(.none)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubViews([self.navigation,self.featureList])
        self.navigation.title = "feature_switch".localized()
        self.navigation.clickClosure = { [weak self] _,_ in
            self?.navigationController?.popViewController(animated: true)
        }
        // Do any additional setup after loading the view.
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    

}

extension FeatureSwitchViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.jsons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "FeatureSwitchCell") as? FeatureSwitchCell
        if cell == nil {
            cell = FeatureSwitchCell(style: .default, reuseIdentifier: "FeatureSwitchCell")
        }
        let info = self.jsons[indexPath.row]
        cell?.featureName.text = info["title"] as? String
        cell?.featureDetail.text = info["detail"] as? String
        if let withSwitch = info["withSwitch"] as? Bool, withSwitch {
            cell?.featureSwitch.tag = indexPath.row
            cell?.featureSwitch.addTarget(self, action: #selector(switchAction(_:)), for: .valueChanged)
            cell?.featureSwitch.isOn = info["switchValue"] as? Bool ?? false
        }
        return cell ?? UITableViewCell()
    }
    
    @objc private func switchAction(_ sender: UISwitch) {
        var info = self.jsons[sender.tag]
        info["switchValue"] = sender.isOn
        if info["title"] as? String == "message_translate".localized() {
            Appearance.chat.enableTranslation = sender.isOn
            self.targetLanguage = sender.isOn
        }
        if info["title"] as? String == "group_topic".localized() {
            self.createTopic = sender.isOn
            if sender.isOn {
                if !Appearance.chat.contentStyle.contains(.withMessageTopic) {
                    Appearance.chat.contentStyle.append(.withMessageTopic)
                }
            } else {
                Appearance.chat.contentStyle.removeAll { $0 == .withMessageTopic }
            }
        }
        if info["title"] as? String == "message_reaction".localized() {
            self.messageReaction = sender.isOn
            if sender.isOn {
                if !Appearance.chat.contentStyle.contains(.withMessageReaction) {
                    Appearance.chat.contentStyle.append(.withMessageReaction)
                }
            } else {
                Appearance.chat.contentStyle.removeAll { $0 == .withMessageReaction }
            }
        }
//        self.featureList.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension FeatureSwitchViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
}
