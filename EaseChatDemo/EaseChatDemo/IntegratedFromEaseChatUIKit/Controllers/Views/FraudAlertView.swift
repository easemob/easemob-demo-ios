//
//  FraudAlertView.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2/12/25.
//

import UIKit
import EaseChatUIKit

final class FraudAlertView: UIView {
    
    lazy var container: UIView = {
        UIView(frame: .zero).backgroundColor(Theme.style == .dark ? UIColor.theme.neutralSpecialColor2:UIColor.theme.neutralSpecialColor9).cornerRadius(4)
    }()
    
    lazy var fraudIcon: UIImageView = {
        UIImageView(frame: .zero).image(UIImage(named: "fraud_icon")).contentMode(.scaleAspectFit)
    }()
    
    lazy var fraudContent: LinkRecognizeTextView = {
        LinkRecognizeTextView(frame: .zero).attributedText(NSAttributedString {
            AttributedText("fraud_alert".localized()).font(.theme.bodySmall).foregroundColor(Theme.style == .dark ? .theme.neutralColor9:.theme.neutralColor3).lineHeight(minimum: 1)
            Link("Click report".localized(), url: URL(string: "https://www.easemob.com")!)
        }).backgroundColor(.clear)
    }()
    
    lazy var close: UIButton = {
        UIButton(type: .custom).image(UIImage(named: "close"), .normal).addTargetFor(self, action: #selector(closeAction), for: .touchUpInside)
    }()
    
    var closeClosure: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.container)
        self.container.translatesAutoresizingMaskIntoConstraints = false
        self.container.topAnchor.constraint(equalTo: self.topAnchor,constant: 8).isActive = true
        self.container.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10).isActive = true
        self.container.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10).isActive = true
        self.container.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.container.addSubViews([self.fraudIcon,self.fraudContent,self.close])
        self.fraudContent.isEditable = false
        self.fraudContent.isScrollEnabled = false
        self.fraudContent.contentInset = .zero
        self.fraudContent.textContainerInset = .zero
        self.fraudContent.textContainer.lineFragmentPadding = 0
        
        self.fraudContent.layoutManager.allowsNonContiguousLayout = false
        self.fraudContent.adjustsFontForContentSizeCategory = true
        self.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.fraudContent.linkTextAttributes = [.foregroundColor: Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5]
        self.fraudIcon.translatesAutoresizingMaskIntoConstraints = false
        self.close.translatesAutoresizingMaskIntoConstraints = false
        self.fraudIcon.topAnchor.constraint(equalTo: self.container.topAnchor,constant: 12).isActive = true
        self.fraudIcon.leadingAnchor.constraint(equalTo: self.container.leadingAnchor,constant: 12).isActive = true
        self.fraudIcon.widthAnchor.constraint(equalToConstant: 13).isActive = true
        self.fraudIcon.heightAnchor.constraint(equalToConstant: 13).isActive = true
        self.fraudContent.translatesAutoresizingMaskIntoConstraints = false
        self.fraudContent.topAnchor.constraint(equalTo: self.container.topAnchor,constant: 12).isActive = true
        self.fraudContent.leadingAnchor.constraint(equalTo: self.fraudIcon.trailingAnchor,constant: 9).isActive = true
        self.fraudContent.trailingAnchor.constraint(equalTo: self.container.trailingAnchor,constant: -36).isActive = true
        self.fraudContent.bottomAnchor.constraint(equalTo: self.container.bottomAnchor,constant: -8).isActive = true
        
        self.close.topAnchor.constraint(equalTo: self.container.topAnchor,constant: 12).isActive = true
        self.close.trailingAnchor.constraint(equalTo: self.container.trailingAnchor,constant: -14).isActive = true
        self.close.widthAnchor.constraint(equalToConstant: 12).isActive = true
        self.close.heightAnchor.constraint(equalToConstant: 12).isActive = true
        let limitHeight = self.fraudContent.sizeThatFits(CGSize(width: self.container.frame.width-65, height: CGFloat.greatestFiniteMagnitude)).height
        self.heightAnchor.constraint(equalToConstant: limitHeight+8).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func closeAction() {
        self.removeFromSuperview()
        self.closeClosure?()
    }
}
