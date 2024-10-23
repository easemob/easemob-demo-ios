//
//  LanguageCell.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/7.
//

import UIKit
import EaseChatUIKit

final class LanguageCell: UITableViewCell {
    
    lazy var content: UILabel = {
        UILabel(frame: CGRect(x: 16, y: 16, width: self.contentView.frame.width-28-32-10, height: 22)).font(UIFont.theme.labelLarge).backgroundColor(.clear)
    }()

    lazy var checkbox: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.contentView.frame.width-16-28, y: (self.contentView.frame.height-28)/2.0, width: 28, height: 28)).backgroundColor(.clear)
    }()
    
    private lazy var separatorLine: UIView = {
        UIView(frame: CGRect(x: self.content.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.content.frame.minX, height: 0.5))
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubViews([self.content,self.checkbox,self.separatorLine])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.checkbox.isUserInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.content.frame = CGRect(x: 16, y: 16, width: self.contentView.frame.width-28-32-10, height: 22)
        self.checkbox.frame = CGRect(x: self.contentView.frame.width-16-28, y: (self.contentView.frame.height-28)/2.0, width: 28, height: 28)
        self.separatorLine.frame = CGRect(x: self.content.frame.minX, y: self.contentView.frame.height-0.5, width: self.frame.width-self.content.frame.minX, height: 0.5)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension LanguageCell: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        var normalImage = UIImage(named: "uncheck")
        if style == .dark {
            normalImage = normalImage?.withTintColor(UIColor.theme.neutralColor4, renderingMode: .alwaysOriginal)
        }
        self.checkbox.image(normalImage, .normal)
        var selectedImage = UIImage(named: "check")
        if style == .dark {
            selectedImage = selectedImage?.withTintColor(UIColor.theme.primaryDarkColor, renderingMode: .alwaysOriginal)
        }
        self.checkbox.image(selectedImage, .selected)
        self.separatorLine.backgroundColor(style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9)
    }
}
