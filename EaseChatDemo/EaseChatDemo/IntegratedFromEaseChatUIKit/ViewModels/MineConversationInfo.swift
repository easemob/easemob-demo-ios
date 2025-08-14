//
//  MineConversationInfo.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 7/25/25.
//

import UIKit
import EaseChatUIKit
import EaseCallUIKit

class MineConversationInfo: ConversationInfo {
    override func contentAttribute() -> NSAttributedString {
        guard let message = self.lastMessage else { return NSAttributedString() }
        var text = NSMutableAttributedString()
        if let dic = message.ext?["ease_chat_uikit_user_info"] as? Dictionary<String,Any> {
            let profile = ChatUserProfile()
            profile.setValuesForKeys(dic)
            profile.id = message.from
            profile.modifyTime = message.timestamp
            ChatUIKitContext.shared?.chatCache?[message.from] = profile
            if ChatUIKitContext.shared?.userCache?[message.from] == nil {
                ChatUIKitContext.shared?.userCache?[message.from] = profile
            } else {
                ChatUIKitContext.shared?.userCache?[message.from]?.nickname = profile.nickname
                ChatUIKitContext.shared?.userCache?[message.from]?.avatarURL = profile.avatarURL
            }
        }
        
        let from = message.from
        let mentionText = "Mentioned".chat.localize
        var user = ChatUIKitContext.shared?.userCache?[from]
        var nickName = user?.remark ?? ""
        if nickName.isEmpty {
            nickName = user?.nickname ?? ""
        }
        if nickName.isEmpty {
            nickName = from
        }
        if message.body.type == .text {
            var result = message.showType
            for (key,value) in ChatEmojiConvertor.shared.oldEmojis {
                result = result.replacingOccurrences(of: key, with: value)
            }
            text.append(NSAttributedString {
                AttributedText(result).foregroundColor(EaseChatUIKit.Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).font(UIFont.theme.bodyLarge)
            })
            let string = text.string as NSString
            for symbol in ChatEmojiConvertor.shared.emojis {
                if string.range(of: symbol).location != NSNotFound {
                    let ranges = text.string.chat.rangesOfString(symbol)
                    text = ChatEmojiConvertor.shared.convertEmoji(input: text, ranges: ranges, symbol: symbol,imageBounds: CGRect(x: 0, y: -3, width: 16, height: 16))
                    text.addAttribute(.font, value: UIFont.theme.bodyLarge, range: NSMakeRange(0, text.length))
                    text.addAttribute(.foregroundColor, value: EaseChatUIKit.Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5, range: NSMakeRange(0, text.length))
                }
            }
            if self.mentioned {
                return super.contentAttribute()
            } else {
                if let callTypeValue = message.ext?[kCallType] as? UInt {
                    let callType = EaseCallUIKit.CallType(rawValue: callTypeValue)
                    
                    switch callType {
                    case .singleAudio:
                        result = "singleAudio".localized()
                    case .singleVideo:
                        result = "singleVideo".localized()
                    case .groupCall:
                        result = "multiCall".localized()
                    
                    default:
                        break
                    }
                    let showText = NSMutableAttributedString {
                        AttributedText("[\(result)]").foregroundColor(EaseCallUIKit.Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).font(Font.theme.bodyMedium)
                    }
                    return showText
                } else {
                    return super.contentAttribute()
                }
            }
        } else {
            let showText = NSMutableAttributedString {
                AttributedText((message.chatType == .chat ? message.showType:(nickName+":"+message.showType))).foregroundColor(EaseCallUIKit.Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).font(UIFont.theme.bodyMedium)
            }
            return showText
        }
    }
}
