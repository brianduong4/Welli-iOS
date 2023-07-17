//
//  HeartRateDataManager.swift
//  Welli-iOS
//
//  Created by Brian Duong on 7/11/23.
//

import Foundation
import HealthKit
import BackgroundTasks
import UserNotifications
import Firebase
import WatchConnectivity

class HeartRateDataManager: NSObject, WCSessionDelegate {
  
    private var session : WCSession? {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            return session
        }
        return nil
    }
    
    private let healthStore = HKHealthStore()
    
    
    
    func requestHealthKitAuthorization() {
        let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("Failed to authorize HealthKit access: \(error.localizedDescription)")
                return
            }
            if success {
                print("HealthKit authorization succeeded")
            } else {
                print("Failed to authorize HealthKit access.")
            }
        }
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if let error = error {
                print("Failed to authorize notification access: \(error.localizedDescription)")
                return
            }
            if success {
                print("Notification authorization succeeded")
            } else {
                print("Failed to authorize notification access.")
            }
        }
    }
    
    func scheduleBackgroundTask() {
        let taskIdentifier = "com.example.backgroundfetch"
        do {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
                self.handleBackgroundTask(task: task)
            }
            
            let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 30) // Adjust the interval as needed
            
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background task: \(error)")
        }
    }
    
    func handleBackgroundTask(task: BGTask) {
        scheduleNextBackgroundTask() // Schedule the next background task
        
        if task is BGAppRefreshTask {
            handleBackgroundFetchTask(task: task as! BGAppRefreshTask)
        } else {
            handleGeneralBackgroundTask()
        }
    }
    
    func scheduleNextBackgroundTask() {
        let taskIdentifier = "com.example.nextbackgroundtask"
        do {
            let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 ) // Adjust the interval as needed; in this case, 1 hour
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to reschedule background task: \(error)")
        }
    }
    
    func handleBackgroundFetchTask(task: BGAppRefreshTask) {
        sendRequestForHeartRate { heartRate in
            print("Background task - heart rate sample: \(heartRate) bpm")
            
            if heartRate > 100 { // Custom threshold value
                self.sendHeartRateNotification(heartRate: heartRate)
                self.storeHeartRateData(heartRate: heartRate)
            }
            
            task.setTaskCompleted(success: true)
        }
    }

    func sendRequestForHeartRate(completion: @escaping (Double) -> Void) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["request" : "heartRate"], replyHandler: { (response) in
                if let heartRate = response["heartRate"] as? Double {
                    DispatchQueue.main.async {
                        completion(heartRate)
                    }
                }
            }, errorHandler: { (error) in
                print("Error sending message: \(error.localizedDescription)")
            })
        }
    }
    
    func handleGeneralBackgroundTask() {
        sendRequestForHeartRate { heartRate in
            print("General task - heart rate sample: \(heartRate) bpm")

            if heartRate > 70 { // Custom threshold value
                self.sendHeartRateNotification(heartRate: heartRate)
                self.storeHeartRateData(heartRate: heartRate)
            }
        }
    }
    
    func sendHeartRateNotification(heartRate: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Heart Rate Alert"
        content.body = "Your heart rate has exceeded the threshold: \(heartRate)"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "heartRateAlert", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func storeHeartRateData(heartRate: Double) {
        let heartRateData = UserDefaults.standard.array(forKey: "HeartRateData") as? [Double] ?? []
        UserDefaults.standard.setValue(heartRateData + [heartRate], forKey: "HeartRateData")
    }
    
    func uploadStoredData(username: String, heartRate: Double) {
        guard !username.isEmpty else {
            print("Username is empty.")
            return
        }

        let heartRateData = UserDefaults.standard.array(forKey: "HeartRateData") as? [Double] ?? []
        let ref = Database.database().reference()
        
        let data: [String: Any] = [
            "heartRate": heartRate,
            "time": "\(Date())",  // Current time
            "type": "threshold",
            "user": username
        ]
        
        ref.child("Notification").child(username).childByAutoId().setValue(data) { error, _ in
            if let error = error {
                print("Error uploading data: \(error)")
            } else {
                print("Data uploaded successfully.")
                UserDefaults.standard.removeObject(forKey: "HeartRateData") // Clear the data after successful upload
            }
        }
    }
    
    func uploadHeartRateDataToWatch(_ heartRateData: [Double]) {
        if WCSession.isSupported() {
            let session = WCSession.default
            if session.isPaired && session.isWatchAppInstalled {
                do {
                    try session.updateApplicationContext(["heartRateData": heartRateData])
                } catch {
                    print("Failed to update application context: \(error)")
                }
            }
        }
    }
    
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCsession inactivre")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let heartRate = applicationContext["heartRate"] as? Double {
            print("Received heart rate: \(heartRate) bpm")
            if heartRate > 70 {
                self.sendHeartRateNotification(heartRate: heartRate)
                self.storeHeartRateData(heartRate: heartRate)
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession failed with error: \(error.localizedDescription)")
        } else {
            print("Activated")
        }
    }
}
