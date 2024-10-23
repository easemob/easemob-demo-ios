//
//  ShowMenuStyleViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/10/10.
//

import UIKit
import EaseChatUIKit

enum ShowMenuStyle {
case longPress
case attachment
}

final class ShowMenuStyleViewController: UIViewController {
    
    @UserDefault("EaseChatDemoPreferencesLongPressStyle", defaultValue: 0) var longPressStyle: UInt8
    
    @UserDefault("EaseChatDemoPreferencesAttachmentStyle", defaultValue: 0) var attachmentStyle: UInt8
    
    public private(set) var style: ShowMenuStyle = .longPress
    
    private var menus = ["style1".localized(),"style2".localized()]
    
    private var styleRawValue: UInt8 = 0
    
    private lazy var navigation: ChatNavigationBar = {
        ChatNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: NavigationHeight),textAlignment: .left,rightTitle: "Confirm".chat.localize)
    }()
    
    private lazy var menuList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: CGFloat(54*self.menus.count)), style: .plain).separatorStyle(.none).tableFooterView(UIView()).backgroundColor(.clear).delegate(self).dataSource(self).rowHeight(54)
    }()
    
    private lazy var stylePreviewLabel: UILabel = {
        UILabel(frame: .zero).font(UIFont.theme.labelLarge).textColor(UIColor.theme.neutralColor5).backgroundColor(.clear).textAlignment(.center).text("style_preview".localized())
    }()
    
    private lazy var stylePreviewContainer: UIImageView = {
        UIImageView(frame: .zero).contentMode(.scaleAspectFit).backgroundColor(.clear)
    }()
    
    public required init(style: ShowMenuStyle) {
        super.init(nibName: nil, bundle: nil)
        self.style = style
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleRawValue = self.style == .longPress ? self.longPressStyle:self.attachmentStyle
        self.view.addSubViews([self.navigation,self.menuList,self.stylePreviewLabel,self.stylePreviewContainer])
        self.setPreviewConstrains()
        self.navigation.title = self.style == .longPress ? "long_press_style".localized():"attachment_menu_style".localized()
        self.navigation.clickClosure = { [weak self] in
            consoleLogInfo("\($1?.row ?? 0)", type: .debug)
            switch $0 {
            case .back:
                self?.navigationController?.popViewController(animated: true)
            case  .rightTitle:
                guard let `self` = self else { return }
                if self.style == .longPress {
                    self.longPressStyle = self.styleRawValue
                    Appearance.chat.messageLongPressMenuStyle = MessageLongPressMenuStyle(rawValue: UInt8(self.styleRawValue)) ?? .actionSheet
                }  else {
                    self.attachmentStyle = self.styleRawValue
                    Appearance.chat.messageAttachmentMenuStyle = MessageAttachmentMenuStyle(rawValue: UInt8(self.styleRawValue)) ?? .actionSheet
                }
                self.navigationController?.popViewController(animated: true)
            default:
                break
            }
            
        }
        // Do any additional setup after loading the view.
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }

    private func setPreviewConstrains() {
        self.stylePreviewContainer.translatesAutoresizingMaskIntoConstraints = false
        self.stylePreviewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            self.stylePreviewContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.stylePreviewContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.stylePreviewContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -24-BottomBarHeight),
            
            self.stylePreviewLabel.bottomAnchor.constraint(equalTo: self.stylePreviewContainer.topAnchor, constant: -24),
            self.stylePreviewLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.stylePreviewLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.stylePreviewLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

}

extension ShowMenuStyleViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MenuStyleCell") as? LanguageCell
        if cell == nil {
            cell = LanguageCell(style: .default, reuseIdentifier: "MenuStyleCell")
        }
        if let title = self.menus[safe:indexPath.row] {
            cell?.content.text = title
            if indexPath.row == self.styleRawValue {
                cell?.checkbox.isSelected = true
            } else {
                cell?.checkbox.isSelected = false
            }
        }
        cell?.accessoryType = .none
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.styleRawValue = UInt8(indexPath.row)
        self.menuList.reloadData()
        self.switchTheme(style: Theme.style)
    }
}

extension ShowMenuStyleViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        var imageName = ""
        if self.style == .longPress {
            if self.styleRawValue == 0 {
                imageName = "msgmenu_style1_"
            } else {
                imageName = "msgmenu_style2_"
            }
        } else {
            if self.styleRawValue == 0 {
                imageName = "attmsg_style1_"
            } else {
                imageName = "attmsg_style2_"
            }
            
        }
        if style == .dark {
            imageName.append("ondark")
        } else {
            imageName.append("onlight")
        }
        self.stylePreviewContainer.image = UIImage(named: imageName)
    }
}
