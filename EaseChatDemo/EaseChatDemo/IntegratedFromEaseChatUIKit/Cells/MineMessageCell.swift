//
//  MineMessageCell.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/4/3.
//

import UIKit
import EaseChatUIKit

final class MineMessageCell: MessageCell {

    override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        if entity.message.chatType == .chat {
            self.nickName.isHidden = true
        } else {
            if entity.message.direction == .send {
                self.nickName.isHidden = true
            } else {
                self.nickName.isHidden = false
            }
        }
    }

}
