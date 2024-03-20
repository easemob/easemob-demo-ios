//
//  AboutEasemobController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/6.
//

import UIKit
import EaseChatUIKit

final class AboutEasemobController: UIViewController {

    private let infos = [["title":"Official Website".localized(),"content":"https://www.huanxin.com"],
                         ["title":"Hotline".localized(),"content":"400-622-1766"],
                         ["title":"Business Cooperation".localized(),"content":"bd@easemob.com"],
                         ["title":"Channel Cooperation".localized(),"content":"qudao@easemob.com"],
                         ["title":"Suggestions".localized(),"content":"issues@easemob.com"]]
    
    private lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: NavigationHeight), textAlignment: .left, rightTitle: nil)
    }()
    
    private lazy var header: AboutEasemobHeader = {
        AboutEasemobHeader(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 221))
    }()
    
    private lazy var menuList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), style: .plain).tableFooterView(UIView()).tableHeaderView(self.header).separatorStyle(.none).dataSource(self).delegate(self).rowHeight(54)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.navigation,self.menuList])
        self.navigation.title = "About".localized()
        self.navigation.clickClosure = { [weak self] _,_ in
            self?.navigationController?.popViewController(animated: true)
        }
        // Do any additional setup after loading the view.
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    

}

extension AboutEasemobController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.infos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AboutEasemobCell") as? AboutEasemobCell
        if cell == nil {
            cell = AboutEasemobCell(style: .subtitle, reuseIdentifier: "AboutEasemobCell")
        }
        cell?.selectionStyle =  .none
        cell?.textLabel?.text = self.infos[safe:indexPath.row]?["title"]
        cell?.detailTextLabel?.text = self.infos[safe:indexPath.row]?["content"]
        return cell ?? AboutEasemobCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = self.infos[safe:indexPath.row]?["title"] ?? ""
        switch title {
        case "Official Website".localized():
            UIApplication.shared.open(URL(string: "https://www.huanxin.com")!, options: [:], completionHandler: nil)
        case "Hotline".localized(): self.makePhoneCall()
        case "Business Cooperation".localized(): self.sendBDEmail()
        case "Channel Cooperation".localized(): self.sendChannelEmail()
        case "Suggestions".localized(): self.sendSuggestionEmail()
        default:
            break
        }
    }
    
    private func makePhoneCall() {
        if let url = URL(string: "tel://4006221766"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func sendBDEmail() {
        if let emailURL = URL(string: "mailto:bd@easemob.com") {
            if UIApplication.shared.canOpenURL(emailURL) {
                UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func sendChannelEmail() {
        if let emailURL = URL(string: "mailto:qudao@easemob.com") {
            if UIApplication.shared.canOpenURL(emailURL) {
                UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func sendSuggestionEmail() {
        if let emailURL = URL(string: "mailto:issues@easemob.com") {
            if UIApplication.shared.canOpenURL(emailURL) {
                UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
            }
        }
    }
}

extension AboutEasemobController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.menuList.reloadData()
    }
}
