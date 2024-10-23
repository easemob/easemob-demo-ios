//
//  MeMenuCell.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/5.
//

import UIKit
import EaseChatUIKit


final class MeMenuCell: UITableViewCell {
    
    lazy var icon: UIImageView = {
        UIImageView(frame: CGRect(x: 16, y: 13, width: self.contentView.frame.height-26, height: self.contentView.frame.height-26)).backgroundColor(.clear)
    }()
    
    lazy var content: UILabel = {
        UILabel(frame: CGRect(x: self.icon.frame.maxX+8, y: 16, width: (self.frame.width-32)/2.0, height: 22)).font(UIFont.theme.labelLarge).backgroundColor(.clear)
    }()
    
    lazy var detail: UILabel = {
        UILabel(frame: CGRect(x: self.frame.width-156, y: 18, width: 120, height: 18)).font(UIFont.theme.labelMedium).textAlignment(.right)
    }()
    
    public private(set) lazy var separatorLine: UIView = {
        UIView(frame: CGRect(x: self.content.frame.minX, y: self.contentView.frame.height - 0.5, width: self.frame.width, height: 0.5))
    }()
    
    lazy var indicator: UIImageView = {
        UIImageView(frame: CGRect(x: self.frame.width-37, y: 0, width: 20, height: 20)).contentMode(.scaleAspectFill).backgroundColor(.clear)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.font(UIFont.theme.labelLarge)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubViews([self.icon,self.content,self.detail,self.indicator,self.separatorLine])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.icon.frame = CGRect(x: 16, y: (self.frame.height-28)/2.0, width: 28, height: 28)
        self.indicator.frame = CGRect(x: self.frame.width-32, y: (self.frame.height-20)/2.0, width: 10, height: 20)
        self.separatorLine.frame = CGRect(x: self.content.frame.minX, y: self.contentView.frame.height - 0.5, width: ScreenWidth, height: 0.5)
    }
    
    func refreshViews(hasIcon: Bool) {
        self.icon.isHidden = !hasIcon
        if hasIcon {
            self.icon.frame = CGRect(x: 16, y: (self.frame.height-28)/2.0, width: 28, height: 28)
            self.icon.center = CGPoint(x: 30, y: self.contentView.frame.height/2.0)
            self.content.frame = CGRect(x: self.icon.frame.maxX+8, y: 16, width: self.frame.width-32-28-8, height: 22)
            self.content.textColor(Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        } else {
            self.icon.frame = .zero
            self.content.frame = CGRect(x: 16, y: 16, width: self.frame.width-32-28-8, height: 22)
            self.content.textColor(Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor)
        }
        self.separatorLine.frame = CGRect(x: self.content.frame.minX, y: self.contentView.frame.height - 0.5, width: ScreenWidth, height: 0.5)
        self.indicator.isHidden = !hasIcon
    }
        
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MeMenuCell: ThemeSwitchProtocol {

    func switchTheme(style: ThemeStyle) {
        
        self.detail.textColor(style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5)
        let image = UIImage(named: "chevron_right", in: .chatBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.neutralColor5:UIColor.theme.neutralColor3)
        self.indicator.image = image
        
        self.separatorLine.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9
    }
}
