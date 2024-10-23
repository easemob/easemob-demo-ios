//
//  ColorHueSettingCell.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/8.
//

import UIKit
import EaseChatUIKit

final class ColorHueSettingCell: UITableViewCell {
    
    var indexPath = IndexPath(row: 0, section: 0)
    
    var sliderValueUpdated: ((CGFloat,IndexPath) -> Void)?
    
    private lazy var colorContainer: UIView = {
        UIView(frame: CGRect(x: 16, y: 13, width: 28, height: 28)).cornerRadius(2).layerProperties(UIColor.theme.neutralColor9, 0.5)
    }()
    
    lazy var colorView: UIView = {
        UIView(frame: CGRect(x: 1, y: 1, width: 26, height: 26)).backgroundColor(UIColor(hue: Appearance.primaryHue, saturation: 1, lightness: CGFloat(50)/100.0, alpha: 1))
    }()
    
    lazy var colorSlider: UISlider = {
        let slider = UISlider(frame: CGRect(x: self.colorContainer.frame.maxX+16, y: self.colorContainer.frame.minY, width: self.contentView.frame.width-self.colorContainer.frame.maxX-16-47-20, height: 24))
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
    }()
    
    lazy var colorValue: UILabel = {
        UILabel(frame: CGRect(x: self.contentView.frame.width-47, y: 0, width: 27, height: 18)).font(UIFont.theme.labelMedium).textColor(UIColor.theme.neutralColor5).textAlignment(.right)
    }()

    lazy var separatorLine: UIView = {
        UIView(frame: .zero)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubViews([self.colorContainer,self.colorSlider,self.colorValue,self.separatorLine])
        self.colorContainer.addSubview(self.colorView)
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.colorContainer.frame = CGRect(x: 16, y: 13, width: 28, height: 28)
        self.colorView.frame = CGRect(x: 1, y: 1, width: 26, height: 26)
        self.colorSlider.frame = CGRect(x: self.colorContainer.frame.maxX+16, y: self.colorContainer.frame.minY, width: self.contentView.frame.width-self.colorContainer.frame.maxX-16-47-20, height: 24)
        self.colorValue.frame = CGRect(x: self.contentView.frame.width-47, y: self.colorSlider.center.y-9, width: 27, height: 18)
        self.separatorLine.frame = CGRect(x: self.colorSlider.frame.minX, y: self.contentView.frame.height-0.5, width: self.frame.width-16, height: 0.5)
    }
    
    @objc private func sliderValueChanged() {
        self.sliderValueUpdated?(CGFloat(self.colorSlider.value),self.indexPath)
//        self.colorView.backgroundColor = UIColor(hue: CGFloat(UInt(self.colorSlider.value))/360, saturation: 1, lightness: CGFloat(UInt(50))/100.0, alpha: 1)
//        self.colorValue.text = "\(Int(self.colorSlider.value))"
    }
    
}

extension ColorHueSettingCell: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.colorContainer.layer.borderColor = style == .dark ? UIColor.theme.neutralColor2.cgColor:UIColor.theme.neutralColor9.cgColor
        self.colorSlider.minimumTrackTintColor = style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
        self.colorValue.textColor = style == .dark ? UIColor.theme.neutralColor5:UIColor.theme.neutralColor6
        self.separatorLine.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9
    }
}
