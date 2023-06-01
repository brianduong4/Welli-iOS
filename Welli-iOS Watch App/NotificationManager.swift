//
//  NotificationManager.swift
//  Welli-iOS Watch App
//
//  Created by Brian Duong on 5/25/23.
//

import Foundation
import UserNotifications
import WatchKit

//---------------------NOTIFICATION LOG------------------------
/*class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {
    
    override init() {
            super.init()
            UNUserNotificationCenter.current().delegate = self
        }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "openAction" {
            recordUserOpenedAppFromNotification()
        }
        completionHandler()
    }
    
    private func recordUserOpenedAppFromNotification() {
        // Record that the user opened the app via a notification
        let currentCount = UserDefaults.standard.integer(forKey: "notificationOpens")
        let newCount = currentCount + 1
        UserDefaults.standard.set(newCount, forKey: "notificationOpens")
    }
}*/

//---------------------LOCAL SCHEDULED NOTIFICATION------------------------
//MARK: METHOD 1
/*
class NotificationManager {
    static func scheduleNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Welli Check-In"
        content.subtitle = "Daily Reminder"
        content.body = "How do you feel? Click the notification to let us know"
        content.sound = UNNotificationSound.default
        
        let notificationTimes: [Int] = [12, 15, 18] // Notification times in 24-hour format
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        let center = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                    guard granted else {
                        print("Notification authorization denied.")
                        return
                    }
                    // Authorization granted, call scheduleNotifications() again on the main queue
                    DispatchQueue.main.async {
                        self.scheduleNotifications()
                    }
                }
                return
            }
            
            center.getPendingNotificationRequests(completionHandler: { requests in
                for request in requests {
                    print(request)
                    print("-----------BEFORE NOTIFICATION REMOVAL-----------")
                }
            })
            
            
            // Clear all previously scheduled notifications
            notificationCenter.removeAllPendingNotificationRequests()
            
            for hour in notificationTimes {
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = 0
                
                let identifier = UUID().uuidString
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                notificationCenter.add(request) { error in
                    if let error = error {
                        print("Failed to schedule notification: \(error.localizedDescription)")
                    } else {
                        print("Notification scheduled successfully")
                    }
                }
            }
            
            
            center.getPendingNotificationRequests(completionHandler: { requests in
                for request in requests {
                    print(request)
                    print("-----------AFTER NOTIFICATION REMOVAL-----------")
                }
            })
            
        }
    }
}

 //MARK: METHOD 2
 
*/
/*class NotificationManager {
    static func scheduleNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Welli Check-In"
        content.subtitle = "Daily Reminder"
        content.body = "How do you feel? Click the notification to let us know"
        content.sound = UNNotificationSound.default
        
        let notificationTimes: [Int] = [13, 14, 15] // Notification times in 24-hour format
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                    guard granted else {
                        print("Notification authorization denied.")
                        return
                    }
                    // Authorization granted, call scheduleNotifications() again on the main queue
                    DispatchQueue.main.async {
                        self.scheduleNotifications()
                    }
                }
                return
            }
            
            // Clear all previously scheduled notifications
            notificationCenter.removeAllPendingNotificationRequests()
            
            for hour in notificationTimes {
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = 0
                
                let identifier = UUID().uuidString
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                notificationCenter.add(request) { error in
                    if let error = error {
                        print("Failed to schedule notification: \(error.localizedDescription)")
                    } else {
                        print("Notification scheduled successfully")
                    }
                }
            }
            
            // Check pending notifications after all have been added
            notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
                print("-----------AFTER NOTIFICATION SCHEDULING-----------")
                for request in requests {
                    print(request)
                }
            })
        }
    }
}*/






