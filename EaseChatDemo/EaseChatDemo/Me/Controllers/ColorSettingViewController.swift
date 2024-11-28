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
        [UIColor.theme.primaryLightColor,UIColor.theme.secondaryColor4,UIColor.theme.errorColor5,UIColor.theme.neutralColor5,UIColor.theme.neutralSpecialColor5]
    }
    
    private lazy var navigation: ChatNavigationBar = {
        ChatNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: NavigationHeight), textAlignment: .left, rightTitle: "Confirm".chat.localize)
    }()
    
    private lazy var infoList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), style: .grouped).separatorStyle(.none).tableFooterView(UIView()).backgroundColor(.clear).delegate(self).dataSource(self).rowHeight(54).sectionHeaderHeight(20).sectionFooterHeight(0)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.navigation,self.infoList])
        // Do any additional setup after loading the view.
        self.navigation.title = "color_setting".localized()
        self.navigation.editMode = false
        self.navigation.clickClosure = { [weak self]  in
            if $0 == .back {
                self?.navigationController?.popViewController(animated: true)
            }
            if $0 == .rightTitle {
                UIColor.ColorTheme.switchHues(hues: [Appearance.primaryHue,Appearance.secondaryHue,Appearance.errorHue,Appearance.neutralHue,Appearance.neutralSpecialHue])
                Theme.switchTheme(style: Theme.style)
                self?.navigationController?.popViewController(animated: true)
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
            UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)).backgroundColor(Theme.style == .dark ? UIColor.theme.neutralColor0:UIColor.theme.neutralColor95)
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
        var color = UIColor.white
        switch indexPath.section {
        case 0:
            Appearance.primaryHue = hue
            color = UIColor(hue: Appearance.primaryHue, saturation: 1, lightness: 50/100.0, alpha: 1)
        case 1:
            Appearance.secondaryHue = hue
            color = UIColor(hue: Appearance.secondaryHue, saturation: 1, lightness: 40/100.0, alpha: 1)
        case 2:
            Appearance.errorHue = hue
            color = UIColor(hue: Appearance.errorHue, saturation: 1, lightness: 50/100.0, alpha: 1)
        case 3:
            Appearance.neutralHue = hue
            
            Appearance.chat.receiveTextColor = Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
            
            Appearance.chat.sendTextColor = Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
                
            Appearance.chat.receiveTranslationColor = Theme.style == .dark ? UIColor.theme.neutralColor7:UIColor.theme.neutralColor5
            color = UIColor(hue: Appearance.neutralHue, saturation: 0.08, lightness: 50/100.0, alpha: 1)
        case 4:
            Appearance.neutralSpecialHue = hue
            Appearance.chat.sendTranslationColor = Theme.style == .dark ? UIColor.theme.neutralSpecialColor2:UIColor.theme.neutralSpecialColor95
            color = UIColor(hue: Appearance.neutralSpecialHue, saturation: 0.36, lightness: 50/100.0, alpha: 1)
        default:
            break
        }
        let cell = self.infoList.cellForRow(at: indexPath) as? ColorHueSettingCell
        cell?.colorView.backgroundColor = color
        cell?.colorValue.text = "\(Int(hue*360))"
     }
}

extension ColorSettingViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
    }
}
