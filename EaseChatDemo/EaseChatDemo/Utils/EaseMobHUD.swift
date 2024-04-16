//
//  EaseMobHUD.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/29.
//

import UIKit
import EaseChatUIKit

final class EaseMobHUD: UIView {
    static let shared = EaseMobHUD()
    
    private var containerView: UIView?
    private var loadingLabel: UILabel?
    
    init() {
        super.init(frame: .zero)
        setupHUD()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHUD() {
        
        let containerView = UIView(frame:  CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let toastView = UIVisualEffectView(effect: UIBlurEffect(style: Theme.style == .dark ? .light:.dark)).cornerRadius(.medium)
        toastView.alpha = 0
        toastView.backgroundColor = Theme.style == .dark ? UIColor.theme.barrageLightColor3:UIColor.theme.barrageDarkColor3
        toastView.translatesAutoresizingMaskIntoConstraints = false
        let content = "Loading...".chat.localize
        let size = content.chat.sizeWithText(font: UIFont.theme.bodyMedium, size: CGSize(width: ScreenWidth-80, height: 999))
        containerView.addSubview(toastView)
        containerView.bringSubviewToFront(toastView)
        var toastWidth = size.width+40
        if toastWidth >= ScreenWidth-80 {
            toastWidth = ScreenWidth - 80
        }
        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            toastView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            toastView.widthAnchor.constraint(lessThanOrEqualToConstant: containerView.frame.width-80),
            toastView.heightAnchor.constraint(greaterThanOrEqualToConstant: size.height+16)
        ])
        
        let label = UILabel().text(content).textColor(UIColor.theme.neutralColor98).textAlignment(.center).numberOfLines(0).backgroundColor(.clear).text("Loading...".chat.localize)
        label.translatesAutoresizingMaskIntoConstraints = false
        toastView.contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -8)
        ])
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            toastView.alpha = 1
        }, completion: { (finished) in
            if finished {
                DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                    toastView.removeFromSuperview()
                }
            }
        })
        
        self.containerView = containerView
    }

}


extension EaseMobHUD {
    
    func show(window: UIWindow) {
        DispatchQueue.main.async {
            guard let containerView = self.containerView else { return }
            
            window.addSubview(containerView)
        }
    }

    func dismiss() {
        DispatchQueue.main.async {
            self.containerView?.removeFromSuperview()
        }
    }
}
