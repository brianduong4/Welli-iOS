// ThresholdNotifier.swift

import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Failed to request authorization for notifications: \(error)")
                return
            }
            if granted {
                print("Authorization for notifications granted.")
            } else {
                print("Authorization for notifications denied.")
            }
        }
    }
    
    func scheduleNotification(with title: String, body: String, interval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
