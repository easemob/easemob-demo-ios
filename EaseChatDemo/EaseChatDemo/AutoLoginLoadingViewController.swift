//
//  AutoLoginLoadingViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/20.
//

import UIKit
import EaseChatUIKit

final class AutoLoginLoadingViewController: UIViewController {
    
    
    private lazy var background: UIImageView = {
        UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)).contentMode(.scaleAspectFill)
    }()
    
    lazy var loadingView: LoadingView = {
        LoadingView(frame: self.view.bounds)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.background,self.loadingView])
        self.loadingView.startAnimating()
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(loadMain), name: Notification.Name(loginSuccessfulSwitchMainPage), object: nil)
    }
    
    @objc private func loadMain() {
        self.loadingView.stopAnimating()
    }

}

extension AutoLoginLoadingViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.background.image = style == .dark ? UIImage(named: "login_bg_dark") : UIImage(named: "login_bg")
    }
}
