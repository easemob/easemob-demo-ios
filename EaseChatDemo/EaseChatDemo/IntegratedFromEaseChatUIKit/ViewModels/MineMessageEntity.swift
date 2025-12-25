//
//  MineMessageEntity.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/7/8.
//

import UIKit
import EaseChatUIKit
import EaseCallUIKit


public enum ChatReceiveMessageState: UInt8 {
    case typing
    case editing
    case end
}


open class MineMessageEntity: MessageEntity {
        
    /// Whether audio message playing or not.
    
    public var downloading = false
    
    
    public var chatType = ChatType.chat
    
    public var editState: ChatReceiveMessageState = .typing
    
    
    open override func customSize() -> CGSize {
        if let body = self.message.body as? ChatCustomMessageBody {
            switch body.event {
            case EaseChatUIKit_user_card_message:
                return CGSize(width: self.historyMessage ? EaseChatUIKit.ScreenWidth-32:limitBubbleWidth, height: contactCardHeight)
            case EaseChatUIKit_alert_message:
                let label = UILabel().numberOfLines(0).lineBreakMode(.byWordWrapping)
                label.attributedText = self.convertTextAttribute()
                let size = label.sizeThatFits(CGSize(width: EaseChatUIKit.ScreenWidth-32, height: 9999))
                return CGSize(width: EaseChatUIKit.ScreenWidth-32, height: size.height+50)
            default:
                return self.message.contentSize
            }
        } else {
            return .zero
        }
    }
        
    open override func convertTextAttribute() -> NSAttributedString? {
        if self.message.messageId.isEmpty {
            return nil
        }
        var text = NSMutableAttributedString()
        if self.message.messageId.isEmpty {
            return NSMutableAttributedString {
                AttributedText("No Messages".chat.localize).foregroundColor(EaseChatUIKit.Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor7).font(UIFont.theme.labelSmall).lineHeight(multiple: 1.15, minimum: 18)
            }
        }
        var textColor = self.message.direction == .send ? Appearance.chat.sendTextColor:Appearance.chat.receiveTextColor
        if self.historyMessage {
            textColor = EaseChatUIKit.Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
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
                            AttributedText(something).foregroundColor(EaseChatUIKit.Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor7).font(UIFont.theme.bodySmall).lineHeight(multiple: 1.15, minimum: 14).alignment(.center)
                        })
                        text.addAttribute(NSAttributedString.Key.foregroundColor, value: EaseChatUIKit.Theme.style == .dark ? Color.theme.primaryColor6:Color.theme.primaryColor5, range: range)
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
                            AttributedText(nickname).foregroundColor(EaseChatUIKit.Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor7).font(UIFont.theme.labelSmall).lineHeight(multiple: 1.15, minimum: 14).alignment(.center)
                        })
                        text.append(NSAttributedString {
                            AttributedText(" "+something).foregroundColor(EaseChatUIKit.Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor7).font(UIFont.theme.bodySmall).lineHeight(multiple: 1.15, minimum: 14).alignment(.center)
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
                if let callTypeValue = self.message.ext?[kCallType] as? UInt,let endReasonValue = self.message.ext?[kCallEndReason] as? UInt {
                    let timeLength = self.message.ext?[kCallDuration] as? Int ?? 0
                    let callType = EaseCallUIKit.CallType(rawValue: callTypeValue)
                    let endReason = EaseCallUIKit.CallEndReason(rawValue: endReasonValue)
                    var callImageColor = UIColor.white
                    if self.message.direction == .send {
                        callImageColor = EaseChatUIKit.Theme.style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
                    } else {
                        callImageColor = EaseChatUIKit.Theme.style == .dark ? UIColor.theme.neutralColor8:UIColor.theme.neutralColor5
                    }
                    var callImage = UIImage(named: "call", in: .chatBundle, with: nil)?.withTintColor(callImageColor)
                    switch callType {
                    case .singleAudio:
                        callImage = UIImage(named: "phone_hang")?.withTintColor(callImageColor)
                    case .singleVideo:
                        callImage = UIImage(named: "video_call")?.withTintColor(callImageColor)
                    default: break
                    }
                    result = "The call end ".localized()
                    var showTime = ""
                    switch endReason {
                    case .hangup:
                        if self.message.chatType == .chat {
                            result = "and the call duration is ".localized()
                            if timeLength > 0 {
                                let hours = UInt(timeLength / 3600)
                                let minutes = UInt((timeLength % 3600) / 60)
                                let seconds = UInt(ceilf(Float(timeLength % 60)))
                                
                                // 使用 String(format:) 来确保两位数格式，不足两位前面补0
                                showTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                            }
                        }
                    case .busy:
                        result = "The other party busy".localized()
                        showTime = ""
                    case .refuse:
                        result = "Refused ".localized()
                        showTime = ""
                    case .remoteRefuse:
                        result = "The other party refused ".localized()
                        showTime = ""
                    case .cancel:
                        result = "The call was canceled".localized()
                        showTime = ""
                    case .remoteCancel:
                        result = "The other party canceled the call".localized()
                        showTime = ""
                    case .noResponse:
                        result = "No response".localized()
                        showTime = ""
                    case .remoteNoResponse:
                        result = "The other party no response".localized()
                        showTime = ""
                    case .abnormalEnd:
                        result = "The call was ended abnormally".localized()
                        showTime = ""
                    case .handleOnOtherDevice:
                        result = "The call was handled on other device".localized()
                        showTime = ""
                    default:
                        break
                    }
                    let showResult = result+showTime
                    if self.message.direction == .send {
                        text.append(NSAttributedString {
                            AttributedText(showResult+" ").foregroundColor(textColor).font(self.historyMessage ? UIFont.theme.bodyMedium:UIFont.theme.bodyLarge).lineHeight(multiple: 1.15, minimum: self.historyMessage ? 16:18).lineBreakMode(.byWordWrapping)
                            ImageAttachment(callImage, bounds: CGRect(x: 0, y: -4, width: 18, height: 18))
                        })
                    } else {
                        text.append(NSAttributedString {
                            ImageAttachment(callImage, bounds: CGRect(x: 0, y: -4, width: 18, height: 18))
                            AttributedText(" "+showResult).foregroundColor(textColor).font(self.historyMessage ? UIFont.theme.bodyMedium:UIFont.theme.bodyLarge).lineHeight(multiple: 1.15, minimum: self.historyMessage ? 16:18).lineBreakMode(.byWordWrapping)
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
                        mentionAttribute.addAttribute(.foregroundColor, value: (EaseChatUIKit.Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor), range: range)
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
                        mentionAttribute.addAttribute(.foregroundColor, value: (EaseChatUIKit.Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor), range: range)
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
                let receiveLinkColor = EaseChatUIKit.Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
                let sendLinkColor = Appearance.chat.sendTextColor
                let color = self.message.direction == .send ? sendLinkColor:receiveLinkColor
                text.addAttributes([.link:linkURL,.underlineStyle:NSUnderlineStyle.single.rawValue,.underlineColor:color,.foregroundColor:color], range: result.range)
            }
        }

        return text
    }
    
}

