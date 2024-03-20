//
//  AboutEasemobCell.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/6.
//

import UIKit
import EaseChatUIKit

final class AboutEasemobCell: UITableViewCell {

    private private(set) lazy var separatorLine: UIView = {
        UIView(frame: CGRect(x: self.textLabel?.frame.minX ?? 16, y: self.contentView.frame.height - 0.5, width: self.contentView.frame.width, height: 0.5))
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.separatorLine)
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let axisX = self.textLabel?.frame.minX ?? 16
        self.separatorLine.frame = CGRect(x: axisX, y: self.contentView.frame.height - 0.5, width: self.contentView.frame.width-axisX, height: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

extension AboutEasemobCell: ThemeSwitchProtocol {

    func switchTheme(style: ThemeStyle) {
        self.textLabel?.textColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        self.accessoryView?.tintColor = style == .dark ? UIColor.theme.neutralColor5:UIColor.theme.neutralColor3
        self.accessoryView?.subviews.first?.tintColor = style == .dark ? UIColor.theme.neutralColor5:UIColor.theme.neutralColor3
        self.detailTextLabel?.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5
        self.separatorLine.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9
    }
}
