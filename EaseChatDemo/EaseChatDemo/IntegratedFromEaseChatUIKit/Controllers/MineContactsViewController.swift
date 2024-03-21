//
//  MineContactsViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/21.
//

import UIKit
import EaseChatUIKit

final class MineContactsViewController: ContactViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigation.status.isHidden = true
        self.navigation.avatarURL = EaseChatUIKitContext.shared?.currentUser?.avatarURL
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
