//
//  MineChatThreadViewModel.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 7/25/25.
//

import UIKit
import EaseChatUIKit

class MineChatThreadViewModel: ChatThreadViewModel {
    
    func inertAlertMessage() {
        if let alertMessage = self.constructMessage(text: "演示功能，无真实数据，仅限体验", type: .alert) {
            ChatClient.shared().chatManager?.getConversationWithConvId(self.to)?.insert(alertMessage, error: nil)
            self.driver?.showMessage(message: alertMessage)
        }
    }
    
    override func messageDidReceived(message: ChatMessage) {
        super.messageDidReceived(message: message)
        self.inertAlertMessage()
    }
}
