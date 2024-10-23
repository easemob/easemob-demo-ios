//
//  MineContactRemarkEditViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/20.
//

import UIKit
import EaseChatUIKit

final class MineContactRemarkEditViewController: UIViewController {

    
    public private(set) var userId: String = ""
    
    public private(set) var raw: String = ""
    
    private var modifySuccess: ((String) -> ())?
    
    public private(set) lazy var navigation: ChatNavigationBar = {
        ChatNavigationBar(textAlignment: .left,rightTitle: "Save".chat.localize)
    }()
    
    lazy var container: UIView = {
        UIView(frame: CGRect(x: 16, y: self.navigation.frame.maxY+16, width: self.view.frame.width-32, height: 114)).backgroundColor(Theme.style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor95).cornerRadius(.extraSmall)
    }()
    
    public private(set) lazy var contentEditor: CustomTextView = {
        CustomTextView(frame: CGRect(x: 16, y: self.container.frame.minY, width: self.view.frame.width-32, height: 72)).delegate(self).font(UIFont.theme.bodyLarge).backgroundColor(.clear)
    }()
    
    lazy var limitCount: UILabel = {
        UILabel(frame: CGRect(x: self.container.frame.maxX-70, y: self.container.frame.maxY-35, width: 54, height: 22)).font(UIFont.theme.bodyLarge).textColor(Theme.style == .dark ? UIColor.theme.neutralColor5:UIColor.theme.neutralColor7).textAlignment(.right)
    }()
    
    @objc public required convenience init(userId: String,rawText: String,modifyClosure: @escaping (String) -> Void) {
        self.init()
        self.userId = userId
        self.raw = rawText
        self.modifySuccess = modifyClosure
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.contentEditor.contentInset = UIEdgeInsets(top: 6, left: 10, bottom: 0, right: 10)
        self.contentEditor.linkTextAttributes = [.foregroundColor:Theme.style == .dark ? UIColor.theme.neutralColor5:UIColor.theme.neutralColor6]
//        self.contentEditor.placeHolderColor = Theme.style == .dark ? UIColor.theme.neutralColor5:UIColor.theme.neutralColor6
        self.contentEditor.placeholder = "Please input".chat.localize
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
        self.view.addSubViews([self.navigation,self.container,self.contentEditor,self.limitCount])
        self.contentEditor.text = self.raw
        self.limitCount.text = "\(self.raw.count)/\(self.textLimit())"
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.contentEditor.becomeFirstResponder()
    }
    
    private func navigationClick(type: ChatNavigationBarClickEvent,indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        case .rightTitle: self.save()
        default:
            break
        }
    }
    
    private func textLimit() -> Int {
        64
    }
    
    private func save() {
        self.view.endEditing(true)
        guard let text = self.contentEditor.text  else { return }
        if text.count > self.textLimit() {
            self.showToast(toast: "Reach content character limit.".chat.localize)
        } else {
            self.modifySuccess?(text)
            self.pop()
        }
        
    }
    
    private func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }

}

extension MineContactRemarkEditViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return false
        }
        self.navigation.rightItem.isEnabled = (!(textView.text ?? "").isEmpty || !text.isEmpty)
        if (textView.text ?? "").count > self.textLimit(),!text.isEmpty {
            self.showToast(toast: "Reach content character limit.".chat.localize)
            return false
        } else {
            return true
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        let limitCount = self.textLimit()
        let count = (textView.text ?? "").count
        if count > limitCount {
            self.showToast(toast: "Reach content character limit.".chat.localize)
            textView.text = textView.text.chat.subStringTo(limitCount)
        }
        self.limitCount.text = "\(count)/\(limitCount)"
    }
}

extension MineContactRemarkEditViewController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.contentEditor.textColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        self.contentEditor.tintColor = style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
    }
    
    
}
