//
//  ExtensionDelegate.swift
//  Welli-iOS Watch App
//
//  Created by Brian Duong on 5/30/23.
//

import Foundation
import WatchKit
import UserNotifications

/*class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching() {
        // Perform any additional app setup here
        registerForNotifications()
    }
    
    func registerForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification response here
        if response.notification.request.identifier == "Threshold-Notification" {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        completionHandler()
    }
}
*/
