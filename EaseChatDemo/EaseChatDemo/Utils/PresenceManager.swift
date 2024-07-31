//
//  PresenceManager.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/6/6.
//

import UIKit
import EaseChatUIKit
import HyphenateChat

@objc public protocol PresenceDidChangedListener: NSObjectProtocol {
    func presenceStatusChanged(users: [String])
}

class PresenceManager: NSObject {
    
    private var handlers:NSHashTable<PresenceDidChangedListener> = NSHashTable<PresenceDidChangedListener>.weakObjects()
    
    func addHandler(handler: PresenceDidChangedListener) {
        if self.handlers.contains(handler) {
            return
        }
        self.handlers.add(handler)
    }
    
    func removeHandler(handler: PresenceDidChangedListener) {
        self.handlers.remove(handler)
    }
    
    enum State: String {
        case offline = "Offline"
        case online = "Online"
        case busy = "Busy"
        case doNotDisturb = "Do Not Disturb"
        case away = "Away"
        case custom = "Custom status"
    }
    
    static let presenceImagesMap: [State: UIImage?] = [
        .online: UIImage(named: "Online"),
        .offline: UIImage(named: "Offline"),
        .busy: UIImage(named: "busy"),
        .doNotDisturb: UIImage(named: "NoDisturb"),
        .away: UIImage(named: "away"),
        .custom: UIImage(named: "custom_status")
    ]
    
    static let showStatusMap: [State: String] = [
        .custom: "Custom Status".localized(),
        .online: "Online".localized(),
        .offline: "Offline".localized(),
        .busy: "Busy".localized(),
        .doNotDisturb: "group_details_switch_donotdisturb".chat.localize,
        .away: "Away".localized()
    ]
        
    static let shared = PresenceManager()
    
    class func status(with presence: EMPresence?) -> State {
        guard let presence = presence, let statusDetails = presence.statusDetails else {
            return .offline
        }
        if statusDetails.count <= 0 {
            return .offline
        }
        var state: State = .offline
        for i in statusDetails {
            if i.status == 1 {
                state = .online
                break
            }
        }
        
        if state != .offline, let statusDescription = presence.statusDescription, statusDescription.count > 0 {
            state = State(rawValue: statusDescription) ?? .custom
            for i in self.showStatusMap where statusDescription == i.value {
                state = i.key
                break
            }
        }
        return state
    }
    
    var currentUserStatus: String {
        guard let currentUsername = ChatClient.shared().currentUsername, let presence = self.presences[currentUsername] else {
            return PresenceManager.showStatusMap[.online]!
        }
        let status = (((presence.statusDescription?.isEmpty ?? true) ? PresenceManager.showStatusMap[.online]:presence.statusDescription )) ?? ""
        return status
    }
    
    var presences:[String:EMPresence] = [:]
        
    private override init() {
        super.init()
        ChatClient.shared().presenceManager?.add(self, delegateQueue: nil)
        ChatClient.shared().add(self, delegateQueue: nil)
    }
    
    func subscribe(members: [String], completion: ((_ presence: [EMPresence]?, _ error: ChatError?) -> Void)?) {
        var index = 0
        var count = members.count
        while count > 0 {
            var range = NSRange(location: index * 100, length: 0)
            if count > 100 {
                range.length = 100
                index += 1
            } else {
                range.length = count
            }
            count -= range.length
            let array = Array(members[range.location..<range.location + range.length])
            ChatClient.shared().presenceManager?.subscribe(array, expiry: 7 * 24 * 3600, completion: { [weak self] presences, error in
                if let presences = presences {
                    var users: [String] = []
                    for presence in presences {
                        if presence.publisher.count > 0 {
                            users.append(presence.publisher)
                            self?.presences[presence.publisher] = presence
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion?(presences, error)
                }
            })
        }
    }

    func unsubscribe(members: [String], completion: ((_ error: ChatError?) -> Void)?) {
        var index = 0
        var count = members.count
        while count > 0 {
            var range = NSRange(location: index * 100, length: 0)
            if count > 100 {
                range.length = 100
                index += 1
            } else {
                range.length = count
            }
            count -= range.length
            let array = Array(members[range.location..<range.location + range.length])
            ChatClient.shared().presenceManager?.unsubscribe(array, completion: { error in
                DispatchQueue.main.async {
                    completion?(error)
                }
            })
        }
    }

    func publishPresence(description: String?, completion: ((_ error: ChatError?) -> Void)?) {
        var description = description
        if description == PresenceManager.showStatusMap[.online] {
            description = nil
        }
        ChatClient.shared().presenceManager?.publishPresence(withDescription: description, completion: { error in
            DispatchQueue.main.async {
                completion?(error)
            }
        })
    }
    
    func fetchPresenceStatus(userId: String, completion: @escaping (_ presence: EMPresence?, _ error: ChatError?) -> Void) {
        ChatClient.shared().presenceManager?.fetchPresenceStatus([userId], completion: { [weak self] presences, error in
            if let presence = presences?.first {
                self?.presences[userId] = presence
                DispatchQueue.main.async {
                    completion(presence,error)
                }
            }
        })
    }
}

extension PresenceManager: EMPresenceManagerDelegate {
    func presenceStatusDidChanged(_ presences: [EMPresence]) {
        let users = presences.map { $0.publisher }
        for presence in presences {
            self.presences[presence.publisher] = presence
        }
        if presences.count > 0 {
            DispatchQueue.main.async {
                for handler in self.handlers.allObjects {
                    handler.presenceStatusChanged(users: users)
                }
            }
        }
    }
}

extension PresenceManager: EMClientDelegate {
    func connectionStateDidChange(_ aConnectionState: EMConnectionState) {
        guard let currentUsername = ChatClient.shared().currentUsername, let presence = self.presences[currentUsername], let statusDetails = presence.statusDetails else {
            return
        }
        if aConnectionState == .disconnected {
            for detail in statusDetails {
                detail.status = 0
            }
            DispatchQueue.main.async {
                for handler in self.handlers.allObjects {
                    handler.presenceStatusChanged(users: [currentUsername])
                }
            }
        }
    }
}

