//
//  NotificationService.swift
//  EMPushServerExt
//
//  Created by 朱继超 on 2024/3/18.
//

import UserNotifications
import EMPushExtension

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        
        EMPushServiceExt.setAppkey("easemob#easeim")
        EMPushServiceExt.receiveRemoteNotificationRequest(request) { [weak self] error in
            if error == nil {
                debugPrint("EMPushServiceExt complete apns delivery")
            } else {
                debugPrint("EMPushServiceExt complete apns delivery error: \(error?.localizedDescription ?? "")")
            }
            if let bestAttemptContent = self?.bestAttemptContent {
                // Modify the notification content here...
                bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
                
                contentHandler(bestAttemptContent)
            }
        }

    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
