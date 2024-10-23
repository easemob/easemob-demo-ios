//
//  MineMessageEntity.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/7/8.
//

import UIKit
import EaseChatUIKit
import EaseCallKit

class MineMessageEntity: MessageEntity {
        
    open override func convertTextAttribute() -> NSAttributedString? {
        if self.message.messageId.isEmpty {
            return nil
        }
        var text = NSMutableAttributedString()
        if self.message.messageId.isEmpty {
            return NSMutableAttributedString {
                AttributedText("No Messages".chat.localize).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor7).font(UIFont.theme.labelSmall).lineHeight(multiple: 1.15, minimum: 18)
            }
        }
        var textColor = self.message.direction == .send ? Appearance.chat.sendTextColor:Appearance.chat.receiveTextColor
        if self.historyMessage {
            textColor = Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        }
        if self.message.body.type != .text, self.message.body.type != .custom {
            text.append(NSAttributedString {
                AttributedText(self.message.showType+self.message.showContent).foregroundColor(textColor).font(self.historyMessage ? UIFont.theme.bodyMedium:UIFont.theme.bodyLarge).lineHeight(multiple: 1.15, minimum: self.historyMessage ? 18:16).lineBreakMode(.byWordWrapping)
            })
            return text
        }
        if self.historyMessage,self.message.body.type == .custom {
            text.append(NSAttributedString {
                AttributedText(self.message.showType+self.message.showContent).foregroundColor(textColor).font(self.historyMessage ? UIFont.theme.bodyMedium:UIFont.theme.bodyLarge).lineBreakMode(.byWordWrapping).lineHeight(multiple: 1.15, minimum: self.historyMessage ? 18:16)
            })
            return text
        }
        if self.message.body.type == .custom,let body = self.message.body as? ChatCustomMessageBody {
            switch body.event {
            case EaseChatUIKit_alert_message:
                if let something = self.message.ext?["something"] as? String {
                    if let threadName = self.message.ext?["threadName"] as? String {
                        let range = something.chat.rangeOfString(threadName)
                        text.append(NSAttributedString {
                            AttributedText(something).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor7).font(UIFont.theme.bodySmall).lineHeight(multiple: 1.15, minimum: 14).alignment(.center)
                        })
                        text.addAttribute(NSAttributedString.Key.foregroundColor, value: Theme.style == .dark ? Color.theme.primaryColor6:Color.theme.primaryColor5, range: range)
                    } else {
                        let user = self.message.user
                        var nickname = user?.remark ?? ""
                        if nickname.isEmpty {
                            nickname = user?.nickname ?? ""
                            if nickname.isEmpty {
                                nickname = self.message.from
                            }
                        }
                        text.append(NSMutableAttributedString {
                            AttributedText(nickname).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor7).font(UIFont.theme.labelSmall).lineHeight(multiple: 1.15, minimum: 14).alignment(.center)
                        })
                        text.append(NSAttributedString {
                            AttributedText(" "+something).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor7).font(UIFont.theme.bodySmall).lineHeight(multiple: 1.15, minimum: 14).alignment(.center)
                        })
                    }
                    
                }
                
            default:
                text.append(NSAttributedString {
                    AttributedText(self.message.showType+self.message.showContent).foregroundColor(textColor).font(self.historyMessage ? UIFont.theme.bodyMedium:UIFont.theme.bodyLarge).lineHeight(multiple: 1.15, minimum: self.historyMessage ? 16:18).lineBreakMode(.byWordWrapping)
                })
                break
            }
            
        } else {
            var result = self.message.showType
            
            for (key,value) in ChatEmojiConvertor.shared.oldEmojis {
                result = result.replacingOccurrences(of: key, with: value)
            }
            if self.message.mention.isEmpty {
                if let timeLength = self.message.ext?["callDuration"] as? Int,let callTypeValue = self.message.ext?["type"] as? Int  {
                    let callType = EaseCallType(rawValue: callTypeValue) ?? .type1v1Audio
                    var callImageColor = UIColor.white
                    if self.message.direction == .send {
                        callImageColor = Theme.style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
                    } else {
                        callImageColor = Theme.style == .dark ? UIColor.theme.neutralColor8:UIColor.theme.neutralColor5
                    }
                    var callImage = UIImage(named: "call", in: .chatBundle, with: nil)?.withTintColor(callImageColor)
                    switch callType {
                    case .type1v1Audio:
                        callImage = UIImage(named: "phone_hang")?.withTintColor(callImageColor)
                    case .type1v1Video:
                        callImage = UIImage(named: "video_call")?.withTintColor(callImageColor)
                    default: break
                    }
                    var showTime = "and the call duration is ".localized()
                    if timeLength > 0 {
                        let hours = UInt(timeLength / 3600)
                        let minutes = UInt((timeLength % 3600) / 60)
                        let seconds = UInt(timeLength % 60)
                        if hours >= 1 {
                            showTime += "\(hours):"
                        }
                        if minutes >= 1 {
                            showTime += " \(minutes):"
                        }
                        if seconds >= 1 {
                            showTime += " \(seconds)"
                        }
                        if Appearance.ease_chat_language == .Chinese {
                            if minutes < 1,hours < 1 {
                                showTime += "秒"
                            }
                        } else {
                            if minutes < 1,hours < 1 {
                                showTime += "s"
                            }
                        }
                    }
                    if self.message.direction == .send {
                        text.append(NSAttributedString {
                            AttributedText(result+showTime+" ").foregroundColor(textColor).font(self.historyMessage ? UIFont.theme.bodyMedium:UIFont.theme.bodyLarge).lineHeight(multiple: 1.15, minimum: self.historyMessage ? 16:18).lineBreakMode(.byWordWrapping)
                            ImageAttachment(callImage, bounds: CGRect(x: 0, y: -4, width: 18, height: 18))
                        })
                    } else {
                        text.append(NSAttributedString {
                            ImageAttachment(callImage, bounds: CGRect(x: 0, y: -4, width: 18, height: 18))
                            AttributedText(" "+result+showTime).foregroundColor(textColor).font(self.historyMessage ? UIFont.theme.bodyMedium:UIFont.theme.bodyLarge).lineHeight(multiple: 1.15, minimum: self.historyMessage ? 16:18).lineBreakMode(.byWordWrapping)
                        })
                    }
                } else {
                    text.append(NSAttributedString {
                        AttributedText(result).foregroundColor(textColor).font(self.historyMessage ? UIFont.theme.bodyMedium:UIFont.theme.bodyLarge).lineHeight(multiple: 1.15, minimum: self.historyMessage ? 16:18).lineBreakMode(.byWordWrapping)
                    })
                }
            } else {
                if self.message.mention == ChatUIKitContext.shared?.currentUserId ?? "" {
                    let mentionUser = ChatUIKitContext.shared?.userCache?[ChatUIKitContext.shared?.currentUserId ?? ""]
                    var nickname = mentionUser?.remark ?? ""
                    if nickname.isEmpty {
                        nickname = mentionUser?.nickname ?? ""
                        if nickname.isEmpty {
                            nickname = ChatUIKitContext.shared?.currentUserId ?? ""
                        }
                    }
                    let content = result
                    
                    let mentionRange = content.lowercased().chat.rangeOfString(nickname)
                    let range = NSMakeRange(mentionRange.location-1, mentionRange.length+1)
                    let mentionAttribute = NSMutableAttributedString {
                        AttributedText(content).foregroundColor(textColor).font(self.historyMessage ? UIFont.theme.bodyMedium:UIFont.theme.bodyLarge).lineHeight(multiple: 1.15, minimum: self.historyMessage ? 16:18).lineBreakMode(Appearance.chat.targetLanguage == .Chinese ? .byCharWrapping:.byWordWrapping)
                    }
                    if mentionRange.location != NSNotFound,mentionRange.length != NSNotFound {
                        mentionAttribute.addAttribute(.foregroundColor, value: (Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor), range: range)
                    }
                    text.append(mentionAttribute)
                } else {
                    let content = result
                    
                    let mentionRange = content.lowercased().chat.rangeOfString(self.message.mention.lowercased())
                    let range = NSMakeRange(mentionRange.location-1, mentionRange.length+1)
                    let mentionAttribute = NSMutableAttributedString {
                        AttributedText(content).foregroundColor(textColor).font(self.historyMessage ? UIFont.theme.bodyMedium:UIFont.theme.bodyLarge).lineHeight(multiple: 1.15, minimum: self.historyMessage ? 16:18).lineBreakMode(.byWordWrapping)
                    }
                    if mentionRange.location != NSNotFound,mentionRange.length != NSNotFound {
                        mentionAttribute.addAttribute(.foregroundColor, value: (Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor), range: range)
                    }
                    text.append(mentionAttribute)
                }
                
            }
            let string = text.string as NSString
            for symbol in ChatEmojiConvertor.shared.emojis {
                if string.range(of: symbol).location != NSNotFound {
                    let ranges = text.string.chat.rangesOfString(symbol)
                    text = ChatEmojiConvertor.shared.convertEmoji(input: text, ranges: ranges, symbol: symbol,imageBounds: CGRect(x: 0, y: -4, width: 18, height: 18))
                    text.addAttribute(.font, value: self.historyMessage ? UIFont.theme.bodyMedium:UIFont.theme.bodyLarge, range: NSMakeRange(0, text.length))
                    text.addAttribute(.foregroundColor, value: textColor, range: NSMakeRange(0, text.length))
                }
            }
            if !Appearance.chat.enableURLPreview {
                return text
            }
            // 创建 NSDataDetector 实例以检测文本中的链接
            guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue ) else {
                return text
            }


            // 检测文本中的链接
            let matches = detector.matches(in: text.string, options: [], range: NSRange(location: 0, length: text.string.count))
            if matches.count == 1 {
                self.containURL = true
            } else {
                self.containURL = false
                self.previewURL = ""
                self.urlPreview = nil
                self.previewResult = .failure
                return text
            }
            if let result = matches.first, result.range.length > 0,result.range.location != NSNotFound,let linkURL = result.url {
                self.previewURL = linkURL.absoluteString
                let receiveLinkColor = Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
                let sendLinkColor = Appearance.chat.sendTextColor
                let color = self.message.direction == .send ? sendLinkColor:receiveLinkColor
                text.addAttributes([.link:linkURL,.underlineStyle:NSUnderlineStyle.single.rawValue,.underlineColor:color,.foregroundColor:color], range: result.range)
            }
        }

        return text
    }
    
}

