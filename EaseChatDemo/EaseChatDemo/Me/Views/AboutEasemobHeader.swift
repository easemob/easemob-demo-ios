//
//  AboutEasemobHeader.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/6.
//

import UIKit
import EaseChatUIKit

final class AboutEasemobHeader: UIView {
    
    private lazy var icon: UIImageView = {
        UIImageView(frame: CGRect(x: self.frame.width/2.0-36, y: 20, width: 72, height: 72)).backgroundColor(.clear).contentMode(.scaleAspectFit).image(UIImage(named: "appicon"))
    }()
    
    private lazy var applicationName: UILabel = {
        UILabel(frame: CGRect(x: 80, y: self.icon.frame.maxY+8, width: self.frame.width-160, height: 22)).font(UIFont.theme.labelLarge).backgroundColor(.clear).textAlignment(.center)
    }()
    
    private lazy var demo_version: UILabel = {
        UILabel(frame: CGRect(x: 80, y: self.applicationName.frame.maxY+4, width: self.frame.width-160, height: 18)).font(UIFont.theme.labelMedium).backgroundColor(.clear).textAlignment(.center)
    }()
    
    private lazy var UIKit_version: UILabel = {
        UILabel(frame: CGRect(x: 80, y: self.demo_version.frame.maxY+4, width: self.frame.width-160, height: 18)).font(UIFont.theme.labelMedium).backgroundColor(.clear).text("UIKit Version "+ChatUIKit_VERSION).textAlignment(.center)
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([self.icon,self.applicationName,self.demo_version,self.UIKit_version])
        self.demo_version.text = "SDK Version "+ChatClient.shared().version
        if let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            self.applicationName.text = appName
        } else if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            self.applicationName.text = appName
        }
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AboutEasemobHeader: ThemeSwitchProtocol {
    
    func switchTheme(style: ThemeStyle) {
        self.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.applicationName.textColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        self.demo_version.textColor(style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5)
        self.UIKit_version.textColor(style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5)
    }
    
    
}
