//
//  UIButton+Throttle.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 7/28/25.
//

import Foundation
import UIKit
import ObjectiveC.runtime

// UIButton扩展
extension UIButton {
    private struct AssociatedKeys {
        static var lastClickTime = "lastClickTime"
        static var clickInterval = "clickInterval"
    }
    
    var clickInterval: TimeInterval {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.clickInterval) as? TimeInterval ?? 0.5
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.clickInterval, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var lastClickTime: TimeInterval {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.lastClickTime) as? TimeInterval ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.lastClickTime, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func isClickValid() -> Bool {
        let currentTime = Date().timeIntervalSince1970
        if currentTime - lastClickTime < clickInterval {
            return false
        }
        lastClickTime = currentTime
        return true
    }
}


