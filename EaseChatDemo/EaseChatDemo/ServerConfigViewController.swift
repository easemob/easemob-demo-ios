//
//  ServerConfigViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/6.
//

import EaseChatUIKit
import UIKit

final class ServerConfigViewController: UIViewController {

    @UserDefault("EaseChatDemoServerConfig", defaultValue: [String: String]()) private
        var serverConfig

    private lazy var background: UIImageView = {
        UIImageView(frame: self.view.bounds).contentMode(.scaleAspectFill)
    }()

    private lazy var navigation: ChatNavigationBar = {
        ChatNavigationBar(
            show: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44),
            textAlignment: .left, rightTitle: "保存".chat.localize)
    }()

    private lazy var applicationField: UITextField = {
        UITextField(
            frame: CGRect(
                x: 16, y: self.navigation.frame.maxY + 12, width: self.view.frame.width - 32,
                height: 48)
        ).cornerRadius(Appearance.avatarRadius).placeholder("请输入App Key").font(
            UIFont.theme.bodyLarge
        ).tag(11).delegate(self)
    }()

    private lazy var customize: UILabel = {
        UILabel(
            frame: CGRect(x: 16, y: self.applicationField.frame.maxY + 28, width: 180, height: 22)
        ).font(UIFont.theme.labelLarge).text("使用自定义服务器").backgroundColor(.clear)
    }()

    private lazy var customizeSwitch: UISwitch = {
        UISwitch(
            frame: CGRect(
                x: self.view.frame.width - 12 - 51, y: self.applicationField.frame.maxY + 23.5,
                width: 51, height: 31))
    }()

    private lazy var protocolSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["TCP", "WebSocket"])
        segment.frame = CGRect(
            x: 16, y: self.customize.frame.maxY + 23, width: self.view.frame.width - 32, height: 40)
        segment.selectedSegmentIndex = 0
        segment.tag = 100
        return segment
    }()

    private lazy var chatServerField: UITextField = {
        UITextField(
            frame: CGRect(
                x: 16, y: self.protocolSegment.frame.maxY + 12, width: self.view.frame.width - 32,
                height: 48)
        ).cornerRadius(Appearance.avatarRadius).placeholder("请输入IM服务器IP地址").font(
            UIFont.theme.bodyLarge
        ).tag(33).delegate(self)
    }()

    private lazy var chatPortField: UITextField = {
        UITextField(
            frame: CGRect(
                x: 16, y: self.chatServerField.frame.maxY + 12, width: self.view.frame.width - 32,
                height: 48)
        ).cornerRadius(Appearance.avatarRadius).placeholder("请输入IM服务器IP端口号").font(
            UIFont.theme.bodyLarge
        ).tag(44).delegate(self)
    }()

    private lazy var restServerField: UITextField = {
        UITextField(
            frame: CGRect(
                x: 16, y: self.chatPortField.frame.maxY + 12, width: self.view.frame.width - 32,
                height: 48)
        ).cornerRadius(Appearance.avatarRadius).placeholder("请输入服务器地址").font(UIFont.theme.bodyLarge)
            .tag(55).delegate(self)
    }()

    private lazy var tlsConnectionLabel: UILabel = {
        UILabel(
            frame: CGRect(x: 16, y: self.restServerField.frame.maxY + 12, width: 180, height: 22)
        ).font(UIFont.theme.labelLarge).text("使用tls连接").backgroundColor(.clear)
    }()

    private lazy var tlsSwitch: UISwitch = {
        UISwitch(
            frame: CGRect(
                x: self.view.frame.width - 12 - 51, y: self.restServerField.frame.maxY + 12,
                width: 51, height: 31))
    }()

    private lazy var ipField: UITextField = {
        UITextField(
            frame: CGRect(
                x: 16, y: self.tlsSwitch.frame.maxY + 12, width: self.view.frame.width - 32,
                height: 48)
        ).cornerRadius(Appearance.avatarRadius).placeholder("请输入RTC服务器IP地址").font(
            UIFont.theme.bodyLarge
        ).tag(66).delegate(self)
    }()

    private lazy var verifyDomainName: UITextField = {
        UITextField(
            frame: CGRect(
                x: 16, y: self.ipField.frame.maxY + 12, width: self.view.frame.width - 32,
                height: 48)
        ).cornerRadius(Appearance.avatarRadius).placeholder("请输入RTC服务器域名").font(
            UIFont.theme.bodyLarge
        ).tag(77).delegate(self)
    }()

    private lazy var appIDField: UITextField = {
        UITextField(
            frame: CGRect(
                x: 16, y: self.verifyDomainName.frame.maxY + 12, width: self.view.frame.width - 32,
                height: 48)
        ).cornerRadius(Appearance.avatarRadius).placeholder("请输入App ID").font(
            UIFont.theme.bodyLarge
        ).tag(88).delegate(self)
    }()

    private lazy var disableTokenValidationLabel: UILabel = {
        UILabel(
            frame: CGRect(x: 16, y: self.appIDField.frame.maxY + 12, width: 140, height: 22)
        ).font(UIFont.theme.labelMedium).text("开启RTC Token验证").textColor(.black).backgroundColor(
            .clear)
    }()

    private lazy var tokenValidationSwitch: UISwitch = {
        UISwitch(
            frame: CGRect(
                x: self.disableTokenValidationLabel.frame.maxX + 12,
                y: self.appIDField.frame.maxY + 12, width: 51, height: 31))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.cornerRadius(Appearance.avatarRadius, [.topLeft, .topRight], .clear, 0)
        self.view.addSubViews([
            self.background, self.navigation, self.applicationField, self.customize,
            self.customizeSwitch, self.protocolSegment, self.chatServerField, self.chatPortField,
            self.restServerField, self.tlsConnectionLabel, self.tlsSwitch, self.ipField,
            self.verifyDomainName, self.appIDField, self.disableTokenValidationLabel,
            self.tokenValidationSwitch,
        ])
        self.customizeSwitch.isOn = self.serverConfig["use_custom_server"] == "1" ? true : false
        self.tokenValidationSwitch.isOn =
            (self.serverConfig["enable_rtc_token_validation"] ?? "1") == "1"
        // Do any additional setup after loading the view.
        self.customizeSwitch.addTarget(
            self, action: #selector(useCustomServer), for: .touchUpInside)
        self.tokenValidationSwitch.addTarget(
            self, action: #selector(tokenValidationChanged), for: .touchUpInside)
        self.navigation.clickClosure = { [weak self] in
            self?.view.endEditing(true)
            consoleLogInfo("\($1?.row ?? 0)", type: .debug)
            switch $0 {
            case .back:
                self?.dismiss(animated: true)
            default:
                if self?.saveServerConfig() ?? true {
                    exit(0)
                }
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

        if let tls = self.serverConfig["tls"] {
            self.tlsSwitch.isOn = tls == "1" ? true : false
        }

        if let isTCP = self.serverConfig["is_tcp"] {
            self.protocolSegment.selectedSegmentIndex = isTCP == "1" ? 0 : 1
        } else {
            self.protocolSegment.selectedSegmentIndex = 0
        }

        if let rtcIp = self.serverConfig["rtc_server_ip"] {
            self.ipField.text = rtcIp
        }

        if let rtcDomain = self.serverConfig["rtc_server_domain"] {
            self.verifyDomainName.text = rtcDomain
        }

        if let appId = self.serverConfig["app_id"] {
            self.appIDField.text = appId
        }

        if let enableTokenValidation = self.serverConfig["enable_rtc_token_validation"] {
            self.tokenValidationSwitch.isOn = enableTokenValidation == "1"
        } else {
            self.tokenValidationSwitch.isOn = true
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    @objc func useCustomServer() {
        if self.customizeSwitch.isOn {
            self.protocolSegment.isEnabled = true
            self.chatServerField.isEnabled = true
            self.chatPortField.isEnabled = true
            self.restServerField.isEnabled = true
            self.tlsSwitch.isEnabled = true
        } else {
            self.protocolSegment.isEnabled = false
            self.chatServerField.isEnabled = false
            self.chatPortField.isEnabled = false
            self.restServerField.isEnabled = false
            self.tlsSwitch.isEnabled = false
        }
    }

    @objc func tokenValidationChanged() {

    }

}

extension ServerConfigViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == self.ipField || textField == self.verifyDomainName
            || textField == self.appIDField, reason == .committed
        {
            UIView.animate(withDuration: 0.2) {
                self.view.frame.origin.y = 0
            }
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.ipField || textField == self.verifyDomainName
            || textField == self.appIDField
        {
            UIView.animate(withDuration: 0.2) {
                self.view.frame.origin.y = -260
            }
        }
        return true
    }

    func saveServerConfig() -> Bool {
        self.view.endEditing(true)
        let appkey = self.applicationField.text ?? ""
        let chatServer = self.chatServerField.text ?? ""
        let chatPort = self.chatPortField.text ?? ""
        let restAddress = self.restServerField.text ?? ""
        let rtcIp = self.ipField.text ?? ""
        let rtcDomain = self.verifyDomainName.text ?? ""
        let appId = self.appIDField.text ?? ""
        if !appkey.isEmpty {
            self.serverConfig["application"] = appkey
        } else {
            self.showToast(toast: "请输入App Key")
            return false
        }
        if self.customizeSwitch.isOn {

            if !chatServer.isEmpty {
                self.serverConfig["chat_server_ip"] = chatServer
            } else {
                self.showToast(toast: "请输入IM服务器IP地址")
                return false
            }

            if !chatPort.isEmpty {
                self.serverConfig["chat_server_port"] = chatPort
            } else {
                self.showToast(toast: "请输入IM服务器IP端口号")
                return false
            }

            if !restAddress.isEmpty {
                self.serverConfig["rest_server_address"] = restAddress
            } else {
                self.showToast(toast: "请输入服务器地址")
                return false
            }

            self.serverConfig["tls"] = self.tlsSwitch.isOn ? "1" : "0"
            self.serverConfig["is_tcp"] = self.protocolSegment.selectedSegmentIndex == 0 ? "1" : "0"
            self.serverConfig["rtc_server_ip"] = rtcIp
            self.serverConfig["rtc_server_domain"] = rtcDomain
            self.serverConfig["app_id"] = appId
        }

        self.serverConfig["use_custom_server"] = self.customizeSwitch.isOn ? "1" : "0"
        self.serverConfig["enable_rtc_token_validation"] =
            self.tokenValidationSwitch.isOn ? "1" : "0"
        return true

    }

}

extension ServerConfigViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.background.image =
            style == .dark ? UIImage(named: "login_bg_dark") : UIImage(named: "login_bg")
        self.navigation.backgroundColor = .clear
        self.customizeSwitch.onTintColor =
            style == .dark ? UIColor.theme.primaryDarkColor : UIColor.theme.primaryLightColor
        self.applicationField.backgroundColor =
            style == .dark ? UIColor.theme.neutralColor1 : UIColor.theme.neutralColor98
        self.applicationField.textColor =
            style == .dark ? UIColor.theme.neutralColor98 : UIColor.theme.neutralColor1
        self.customize.textColor(
            style == .dark ? UIColor.theme.neutralColor98 : UIColor.theme.neutralColor1)
        self.chatServerField.backgroundColor = self.applicationField.backgroundColor
        self.chatPortField.backgroundColor = self.applicationField.backgroundColor
        self.restServerField.backgroundColor = self.applicationField.backgroundColor
        self.chatServerField.textColor = self.applicationField.textColor
        self.chatPortField.textColor = self.applicationField.textColor
        self.restServerField.textColor = self.applicationField.textColor
        self.tlsConnectionLabel.textColor(
            style == .dark ? UIColor.theme.neutralColor98 : UIColor.theme.neutralColor1)
        self.ipField.backgroundColor = self.applicationField.backgroundColor
        self.ipField.textColor = self.applicationField.textColor
        self.verifyDomainName.backgroundColor = self.applicationField.backgroundColor
        self.verifyDomainName.textColor = self.applicationField.textColor
        self.appIDField.backgroundColor = self.applicationField.backgroundColor
        self.appIDField.textColor = self.applicationField.textColor
    }
}
