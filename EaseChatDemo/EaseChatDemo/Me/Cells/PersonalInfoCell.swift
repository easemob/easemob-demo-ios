//
//  PersonalInfoCell.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/6.
//

import UIKit
import EaseChatUIKit

final class PersonalInfoCell: UITableViewCell {

    private lazy var titleLabel: UILabel = {
        UILabel(frame: CGRect(x: 16, y: 16, width: self.frame.width/2.0-26, height: 22)).font(UIFont.theme.labelLarge).backgroundColor(.clear).font(UIFont.theme.labelLarge)
    }()
    
    private lazy var detailLabel: UILabel = {
        UILabel(frame: CGRect(x: self.frame.width/2.0, y: 16, width: self.frame.width/2.0-80, height: 22)).tag(12).backgroundColor(.clear).font(UIFont.theme.labelLarge).textAlignment(.right)
    }()
    
    private lazy var detailImage: ImageView = {
        ImageView(frame: CGRect(x: self.frame.width-76, y: 7, width: 40, height: 40)).cornerRadius(Appearance.avatarRadius).contentMode(.scaleToFill)
    }()
    
    private lazy var separatorLine: UIView = {
        UIView(frame: CGRect(x: self.titleLabel.frame.minX, y: self.contentView.frame.height - 0.5, width: self.frame.width-self.titleLabel.frame.minX, height: 0.5))
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubViews([self.titleLabel,self.detailLabel,self.detailImage,self.separatorLine])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame = CGRect(x: 16, y: 16, width: self.frame.width/2.0-26, height: 22)
        self.detailLabel.frame = CGRect(x: self.frame.width/2.0, y: 16, width: self.frame.width/2.0-30, height: 22)
        self.detailImage.frame = CGRect(x: self.frame.width-76, y: 7, width: 40, height: 40)
        self.separatorLine.frame = CGRect(x: self.titleLabel.frame.minX, y: self.contentView.frame.height - 0.5, width: self.frame.width, height: 0.5)
    }
    
    func refresh(title: String, detail: String) {
        self.titleLabel.text = title
        if title == "Avatar".localized() {
            self.detailImage.isHidden = false
            self.detailLabel.isHidden = true
            self.detailImage.image(with: detail, placeHolder: Appearance.conversation.singlePlaceHolder)
        } else {
            self.detailImage.isHidden = true
            self.detailLabel.isHidden = false
            self.detailLabel.text = detail
        }
    }
}

extension PersonalInfoCell: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.titleLabel.textColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        self.detailLabel.textColor(style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5)
        self.separatorLine.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9
        self.accessoryView?.tintColor = style == .dark ? UIColor.theme.neutralColor5:UIColor.theme.neutralColor3
        self.accessoryView?.subviews.first?.tintColor = style == .dark ? UIColor.theme.neutralColor5:UIColor.theme.neutralColor3
    }
}
