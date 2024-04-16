//
//  DemoLanguage.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/7.
//

import Foundation
import EaseChatUIKit

struct DemoLanguage {
    
    static let shared = DemoLanguage()
    
    public static func localValue(key: String) -> String {
        DemoLanguage.shared.localValue(key)
    }

    private func localValue(_ key: String) -> String {
        guard var lang = NSLocale.preferredLanguages.first else { return Bundle.main.bundlePath }
        if !Appearance.ease_chat_language.rawValue.isEmpty {
            lang = Appearance.ease_chat_language.rawValue
        }
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj") ?? ""
        let pathBundle = Bundle(path: path) ?? .main
        let value = pathBundle.localizedString(forKey: key, value: nil, table: nil)
        return value
    }

    static func chineseLanguage() -> Bool {
        guard let lang = NSLocale.preferredLanguages.first else { return false }
        if lang.contains("zh") {
            return true
        } else {
            return false
        }
    }
}
