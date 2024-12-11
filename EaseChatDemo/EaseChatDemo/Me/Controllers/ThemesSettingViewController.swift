//
//  ThemesViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/8.
//

import UIKit
import EaseChatUIKit

final class ThemesSettingViewController: UIViewController {
    
    @UserDefault("EaseChatDemoPreferencesTheme", defaultValue: 0) var theme: UInt

    private var infos = ["Classic".localized(),"Smart".localized()]
    
    private var selectIndexPath = IndexPath(row: 0, section: 0)
        
    private lazy var navigation: ChatNavigationBar = {
        ChatNavigationBar(show: CGRect(x: 0, y: 0, width: self.view.frame.width, height: NavigationHeight),textAlignment: .left,rightTitle: "Confirm".chat.localize)
    }()
    
    private lazy var infoList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), style: .plain).separatorStyle(.none).tableFooterView(UIView()).backgroundColor(.clear).delegate(self).dataSource(self).rowHeight(54)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectIndexPath = IndexPath(row: Int(self.theme), section: 0)
        self.view.addSubViews([self.navigation,self.infoList])
        self.navigation.title = "switch_theme".localized()
        self.navigation.clickClosure = { [weak self] in
            consoleLogInfo("\($1?.row ?? 0)", type: .debug)
            switch $0 {
            case .back:
                self?.navigationController?.popViewController(animated: true)
            case  .rightTitle:
                DialogManager.shared.showAlert(title: "Switch Theme".localized(), content: "Switch Theme".localized()+"Terminal Alert".localized(), showCancel: true, showConfirm: true) { [weak self] _ in
                    guard let `self` = self else { return }
                    self.theme = UInt(self.selectIndexPath.row)
                    DispatchQueue.main.asyncAfter(wallDeadline: .now()+0.5) {
                        exit(0)
                    }
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

extension ThemesSettingViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.infos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell") as? LanguageCell
        if cell == nil {
            cell = LanguageCell(style: .default, reuseIdentifier: "ThemeCell")
        }
        if let title = self.infos[safe:indexPath.row] {
            cell?.content.text = title
            cell?.checkbox.isSelected = self.selectIndexPath.row == indexPath.row
        }
        cell?.accessoryType = .none
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectIndexPath = indexPath
        self.infoList.reloadData()
    }
}

extension ThemesSettingViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
    }
}
