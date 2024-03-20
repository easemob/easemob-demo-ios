//
//  ColorSettingViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/7.
//

import UIKit
import EaseChatUIKit

final class ColorSettingViewController: UIViewController {
    
    private var sectionTitles = ["primary hue".localized(),"secondary hue".localized(),"error hue".localized(),"neutralHue".localized(),"neutral special hue".localized()]
    
    private var hues: [CGFloat] {
        [Appearance.primaryHue,Appearance.secondaryHue,Appearance.errorHue,Appearance.neutralHue,Appearance.neutralSpecialHue]
    }
    
    private var hueColors: [UIColor] {
        [UIColor.theme.primaryColor5,UIColor.theme.secondaryColor4,UIColor.theme.errorColor5,UIColor.theme.neutralColor5,UIColor.theme.neutralSpecialColor5]
    }
    
    private lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: NavigationHeight), textAlignment: .left, rightTitle: "Confirm".chat.localize)
    }()
    
    private lazy var infoList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), style: .plain).separatorStyle(.none).tableFooterView(UIView()).backgroundColor(.clear).delegate(self).dataSource(self).rowHeight(54).sectionHeaderHeight(20)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.navigation,self.infoList])
        // Do any additional setup after loading the view.
        self.navigation.title = "color_setting".localized()
        self.navigation.clickClosure = { [weak self]  in
            if $0 == .back {
                self?.navigationController?.popViewController(animated: true)
            }
            if $0 == .rightTitle {
                Theme.switchTheme(style: .custom)
            }
            consoleLogInfo("\($1?.row ?? 0)", type: .debug)
        }
        // Do any additional setup after loading the view.
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    

    

}

extension ColorSettingViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView {
            UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
            UILabel(frame: CGRect(x: 16, y: 0, width: self.view.frame.width-32, height: 20)).font(UIFont.theme.labelMedium).textColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).text(self.sectionTitles[section])
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ColorHueSettingCell") as? ColorHueSettingCell
        if cell == nil {
            cell = ColorHueSettingCell(style: .default, reuseIdentifier: "ColorHueSettingCell")
        }
        if let color = self.hueColors[safe: indexPath.section],let hueValue = self.hues[safe: indexPath.section] {
            cell?.indexPath = indexPath
            cell?.colorView.backgroundColor = color
            cell?.colorSlider.setValue(Float(hueValue), animated: true)
            cell?.colorValue.text = "\(Int(hueValue*360))"
        }
        cell?.sliderValueUpdated = { [weak self] in
            self?.updateHues(hue: $0, indexPath: $1)
        }
        cell?.accessoryType = .none
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    private func updateHues(hue: CGFloat,indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            Appearance.primaryHue = hue
        case 1:
            Appearance.secondaryHue = hue
        case 2:
            Appearance.errorHue = hue
        case 3:
            Appearance.neutralHue = hue
        case 4:
            Appearance.neutralSpecialHue = hue
        default:
            break
        }
        self.infoList.reloadData()
    }
}

extension ColorSettingViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
    }
}
