//
//  SceneDelegate.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/5.
//

import UIKit
import EaseChatUIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    @UserDefault("EaseChatDemoDarkMode", defaultValue: false) var darkMode: Bool
    
    @UserDefault("EaseChatDemoPreferencesLanguage", defaultValue: "zh-Hans") var language: String
    
    @UserDefault("EasemobUser",defaultValue: Dictionary<String,Dictionary<String,Any>>()) private var userData
    

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        Appearance.ease_chat_language = LanguageType(rawValue: self.language) ?? .Chinese
        self.window = nil
        self.window = UIWindow(windowScene: windowScene)
        self.chooseRootViewController()
        self.window?.makeKeyAndVisible()
        self.switchTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(loadMain), name: NSNotification.Name(loginSuccessfulSwitchMainPage), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadLogin), name: NSNotification.Name(backLoginPage), object: nil)
    }
    
    private func switchTheme() {
        Theme.registerSwitchThemeViews(view: self)
        Theme.switchTheme(style: self.darkMode ? .dark:.light)
        self.switchTheme(style: self.darkMode ? .dark:.light)
    }
    
    private func chooseRootViewController() {
        if !ChatClient.shared().isAutoLogin {
            self.window?.rootViewController = LoginViewController()
        } else {
            guard let userId = ChatClient.shared().currentUsername else {
                self.window?.rootViewController = LoginViewController()
                return
            }
            let user = EaseProfile()
            if let userInfo = self.userData[userId]?[userId] as? [String : Any] {
                user.setValuesForKeys(userInfo)
            }
            if user.id.isEmpty {
                user.id = userId
            }
            EaseChatUIKitContext.shared?.currentUser = user
            self.window?.rootViewController = MainViewController()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        let style = self.window?.traitCollection.userInterfaceStyle ??  .light
        self.switchTheme(style: style == .light ? .light:.dark)
        ChatClient.shared().applicationWillEnterForeground(UIApplication.shared)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        ChatClient.shared().applicationDidEnterBackground(UIApplication.shared)
    }

    @objc private func loadMain() {
        self.window?.rootViewController = MainViewController()
    }
    
    @objc private func loadLogin() {
        self.window?.rootViewController = LoginViewController()
    }

}

extension SceneDelegate: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.window?.backgroundColor = style == .dark ? UIColor.theme.neutralColor1 : UIColor.theme.neutralColor98
        UIApplication.shared.windows.forEach { $0.overrideUserInterfaceStyle = (style == .dark ? .dark:.light) }
    }
}
