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
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(textAlignment: .left,rightTitle: "Save".chat.localize)
    }()
    
    public private(set) lazy var contentEditor: PlaceHolderTextView = {
        PlaceHolderTextView(frame: CGRect(x: 16, y: self.navigation.frame.maxY+16, width: self.view.frame.width-32, height: 35)).delegate(self).font(UIFont.theme.bodyLarge).backgroundColor(Theme.style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor95).cornerRadius(.small)
    }()
    
    @objc public required convenience init(userId: String,rawText: String,modifyClosure: @escaping (String) -> Void) {
        self.init()
        self.userId = userId
        self.raw = rawText
        self.modifySuccess = modifyClosure
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.contentEditor.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.contentEditor.placeHolderColor = Theme.style == .dark ? UIColor.theme.neutralColor5:UIColor.theme.neutralColor6
        self.contentEditor.placeHolder = "Please input".chat.localize
        self.navigation.title = "Modify Remark".localized()
        self.contentEditor.text = self.raw
        self.contentEditor.autoresizingMask = .flexibleHeight
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
        self.view.addSubViews([self.navigation,self.contentEditor])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.contentEditor.becomeFirstResponder()
    }
    
    private func navigationClick(type: EaseChatNavigationBarClickEvent,indexPath: IndexPath?) {
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
        self.navigation.rightItem.isEnabled = (!(textView.text ?? "").isEmpty || !text.isEmpty)
        if text.count + (textView.text ?? "").count > self.textLimit() {
            self.showToast(toast: "Reach content character limit.".chat.localize)
            return false
        } else {
            return true
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        let limitCount = self.textLimit()
        if (textView.text ?? "").count > limitCount {
            self.showToast(toast: "Reach content character limit.".chat.localize)
            textView.text = textView.text.chat.subStringTo(limitCount)
        } else {
            let fixedWidth = textView.frame.size.width
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        }
        
    }
}

extension MineContactRemarkEditViewController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.contentEditor.textColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
    }
    
    
}
