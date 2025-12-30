//
//  CommonWebViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 12/11/25.
//

import UIKit
import EaseChatUIKit
import WebKit

final class CommonWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    private lazy var navigation: ChatNavigationBar = {
        ChatNavigationBar(
            show: CGRect(x: 0, y: 0, width: self.view.frame.width, height: NavigationHeight),
            textAlignment: .center,
            rightTitle: nil
        )
    }()
    
    private lazy var progressView: UIProgressView = {
        let p = UIProgressView(progressViewStyle: .default)
        p.trackTintColor = UIColor.clear
        p.progressTintColor = Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
        p.isHidden = true
        return p
    }()
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = self
        wv.uiDelegate = self
        wv.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor1 : UIColor.theme.neutralColor98
        wv.scrollView.alwaysBounceVertical = false
        return wv
    }()
    
    private var url: URL?
    
    private var navigationTitle: String = ""
    
    private var localInfo: Dictionary<String, Any> = [:]
    
    convenience init(urlString: String,navigationTitle: String,localInfo: Dictionary<String, Any> = [:]) {
        self.init()
        self.url = URL(string: urlString)
        self.navigationTitle = navigationTitle
        self.localInfo = localInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.localInfo.isEmpty {
            self.view.addSubViews([navigation, progressView, webView])
        } else {
            self.view.addSubViews([navigation, webView])
        }
        
        navigation.title = self.navigationTitle
        navigation.clickClosure = { [weak self] _, _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        setupConstraints()
        addProgressObserver()
        loadWebContent()
    }
    
    private func setupConstraints() {
        navigation.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        if self.localInfo.isEmpty {
            NSLayoutConstraint.activate([
                navigation.topAnchor.constraint(equalTo: view.topAnchor),
                navigation.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigation.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navigation.heightAnchor.constraint(equalToConstant: NavigationHeight),
                
                progressView.topAnchor.constraint(equalTo: navigation.bottomAnchor),
                progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                progressView.heightAnchor.constraint(equalToConstant: 2),
                
                webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                navigation.topAnchor.constraint(equalTo: view.topAnchor),
                navigation.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigation.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navigation.heightAnchor.constraint(equalToConstant: NavigationHeight),
                
                webView.topAnchor.constraint(equalTo: navigation.bottomAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
    }
    
    private func loadWebContent() {
        if let url = self.url {
            if url.absoluteString.hasPrefix("/private/var/containers/") {
                guard let htmlPath = Bundle.main.path(forResource: "person-info", ofType: "html") else {
                    print("HTML 文件未找到")
                    return
                }
                let htmlURL = URL(fileURLWithPath: htmlPath)
                // 允许读取本地资源（如图片、CSS，如果有的话）
                webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
            } else {
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    

    
}

extension CommonWebViewController {
    private func addProgressObserver() {
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress" {
            let progress = Float(webView.estimatedProgress)
            progressView.isHidden = progress == 1
            
            progressView.setProgress(progress, animated: true)
            
            if progress >= 1.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                    self?.progressView.isHidden = true
                    self?.progressView.setProgress(0.0, animated: false)
                }
            }
        }
    }
    
    // 假设 webView 已加载本地 HTML 文件
    func injectPrivacyData(to webView: WKWebView,
                           username: String?,
                           avatarURL: String?,
                           phone: String?,
                           device: String?) {

//        let jsObject: [String: Any] = [
//            "username": username ?? "",
//            "avatar": avatarURL ?? "",
//            "phone": phone ?? "",
//            "device": device ?? ""
//        ]
//
//        // 将字典转为 JSON 字符串
//        if let jsonData = try? JSONSerialization.data(withJSONObject: jsObject),
//           let jsonString = String(data: jsonData, encoding: .utf8) {
//
//            let script = "window.injectUserPrivacyData(\(jsonString));"
//            
//            webView.evaluateJavaScript(script) { (result, error) in
//                if let error = error {
//                    print("注入数据失败: \(error)")
//                } else {
//                    print("隐私数据注入成功")
//                }
//            }
//        }
    }

    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 页面加载完成后注入数据
        if let username = localInfo["username"] as? String,
           let avatarURL = localInfo["avatar"] as? String,
           let phone = localInfo["phone"] as? String,
           let device = localInfo["device"] as? String {
            injectPrivacyData(to: webView, username: username, avatarURL: avatarURL, phone: phone, device: device)
            return
        }
    }
}
