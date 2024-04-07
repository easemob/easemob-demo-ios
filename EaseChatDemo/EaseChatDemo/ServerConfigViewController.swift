//
//  ServerConfigViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/6.
//

import UIKit
import EaseChatUIKit

final class ServerConfigViewController: UIViewController {
    
    @UserDefault("EaseChatDemoServerConfig", defaultValue: Dictionary<String,String>()) private var serverConfig
    
    private lazy var background: UIImageView = {
        UIImageView(frame: self.view.bounds).contentMode(.scaleAspectFill)
    }()
    
    private lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44),textAlignment: .left,rightTitle: "保存".chat.localize)
    }()
    
    private lazy var applicationField: UITextField = {
        UITextField(frame: CGRect(x: 16, y: self.navigation.frame.maxY+12, width: self.view.frame.width-32, height: 48)).cornerRadius(Appearance.avatarRadius).placeholder("请输入App Key").font(UIFont.theme.bodyLarge).tag(11).delegate(self)
    }()
    
    private lazy var customize: UILabel = {
        UILabel(frame: CGRect(x: 16, y: self.applicationField.frame.maxY+28, width: 180, height: 22)).font(UIFont.theme.labelLarge).text("使用自定义服务器").backgroundColor(.clear)
    }()
    
    private lazy var customizeSwitch: UISwitch = {
        UISwitch(frame: CGRect(x: self.view.frame.width-12-51, y: self.applicationField.frame.maxY+23.5, width: 51, height: 31))
    }()
    
    private lazy var chatServerField: UITextField = {
        UITextField(frame: CGRect(x: 16, y: self.customize.frame.maxY+23, width: self.view.frame.width-32, height: 48)).cornerRadius(Appearance.avatarRadius).placeholder("请输入IM服务器IP地址").font(UIFont.theme.bodyLarge).tag(33).delegate(self)
    }()
    
    private lazy var chatPortField: UITextField = {
        UITextField(frame: CGRect(x: 16, y: self.chatServerField.frame.maxY+12, width: self.view.frame.width-32, height: 48)).cornerRadius(Appearance.avatarRadius).placeholder("请输入IM服务器IP端口号").font(UIFont.theme.bodyLarge).tag(44).delegate(self)
    }()
    
    private lazy var restServerField: UITextField = {
        UITextField(frame: CGRect(x: 16, y: self.chatPortField.frame.maxY+12, width: self.view.frame.width-32, height: 48)).cornerRadius(Appearance.avatarRadius).placeholder("请输入服务器地址").font(UIFont.theme.bodyLarge).tag(55).delegate(self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.cornerRadius(Appearance.avatarRadius, [.topLeft,.topRight], .clear, 0)
        self.view.addSubViews([self.background,self.navigation,self.applicationField,self.customize,self.customizeSwitch,self.chatServerField,self.chatPortField,self.restServerField])
        // Do any additional setup after loading the view.
        self.navigation.clickClosure = { [weak self] in
            self?.view.endEditing(true)
            consoleLogInfo("\($1?.row ?? 0)", type: .debug)
            switch $0 {
            case .back:
                self?.dismiss(animated: true)
            default:
                exit(0)
            }
        }
        self.setFields()
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    private func setFields() {
        if let applicationKey = self.serverConfig["application"] {
            self.applicationField.text = applicationKey
        }
    
        if let chatServer = self.serverConfig["chat_server_ip"] {
            self.chatServerField.text = chatServer
        }
    
        if let chatPort = self.serverConfig["chat_server_port"] {
            self.chatPortField.text = chatPort
        }

        if let restAddress = self.serverConfig["rest_server_address"] {
            self.restServerField.text = restAddress
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

}

extension ServerConfigViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if reason == .committed {
            switch textField.tag {
            case 11:
                self.serverConfig["application"] = textField.text
            case 33:
                self.serverConfig["chat_server_ip"] = textField.text
            case 44:
                self.serverConfig["chat_server_port"] = textField.text
            case 55:
                self.serverConfig["rest_server_address"] = textField.text
            default:
                break
            }
        }
    }
}

extension ServerConfigViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.background.image = style == .dark ? UIImage(named: "login_bg_dark"):UIImage(named: "login_bg")
        self.navigation.backgroundColor = .clear
        self.customizeSwitch.onTintColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
        self.applicationField.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.applicationField.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        self.customize.textColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        self.chatServerField.backgroundColor = self.applicationField.backgroundColor
        self.chatPortField.backgroundColor = self.applicationField.backgroundColor
        self.restServerField.backgroundColor = self.applicationField.backgroundColor
        self.chatServerField.textColor = self.applicationField.textColor
        self.chatPortField.textColor = self.applicationField.textColor
        self.restServerField.textColor = self.applicationField.textColor
    }
}


