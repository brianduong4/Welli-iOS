//
//  Welli_iOSApp.swift
//  Welli-iOS
//
//  Created by Brian Duong on 4/4/23.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseDatabase
import HealthKit
import BackgroundTasks
import UserNotifications
import WatchConnectivity


//@main
struct Welli_iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        FirebaseApp.configure()
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/*@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate{
    var window: UIWindow?
    let healthStore = HKHealthStore()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
            // Firebase configuration
            FirebaseApp.configure()
            
            // Request HealthKit authorization
            requestHealthKitAuthorization()
            
            // Request notification authorization
            requestNotificationAuthorization()
            
            // Schedule the initial background task
            scheduleBackgroundTask()
            
            // Watch Connectivity setup
            if WCSession.isSupported() {
                let session = WCSession.default
                session.delegate = self
                session.activate()
            }
            
            return true
        }
    
    // MARK: WCSessionDelegate methods
        func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            // handle session activation completion here
        }

        func sessionDidBecomeInactive(_ session: WCSession) {
            // handle session becoming inactive
        }

        func sessionDidDeactivate(_ session: WCSession) {
            // handle session deactivation
            // you need to reactivate here
            session.activate()
        }

        func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
            if let heartRate = message["heartRate"] as? Double {
                // Do something with the received heart rate data
                print("Received heart rate: \(heartRate) bpm")
                uploadStoredData(username: message["user"] as! String, heartRate: heartRate)
            }
        }
        
         func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
            if let heartRateData = message["heartRateData"] as? [Double] {
                // Do something with the received heart rate data
                print("Received heart rate data: \(heartRateData)")
                uploadBatchedHeartRateData(username: message["user"] as! String, heartRateData: heartRateData)
            }
        }
    
    func uploadBatchedHeartRateData(username: String, heartRateData: [Double]) {
            guard !username.isEmpty else {
                print("Username is empty.")
                return
            }

            let ref = Database.database().reference()
            let timestamp = Date().timeIntervalSince1970

            for heartRate in heartRateData {
                let data: [String: Any] = [
                    "heartRate": heartRate,
                    "time": "\(timestamp)",
                    "type": "batch",
                    "user": username
                ]

                ref.child("Notification").child(username).childByAutoId().setValue(data) { error, _ in
                    if let error = error {
                        print("Error uploading data: \(error)")
                    } else {
                        print("Data uploaded successfully.")
                    }
                }
            }
        }
    
    func requestHealthKitAuthorization() {
        let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization succeeded")
            } else {
                print("Failed to authorize HealthKit access: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                print("Notification authorization succeeded")
            } else {
                print("Failed to authorize notification access: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func scheduleBackgroundTask() {
        let taskIdentifier = "edu.gmu.Welli-iOS.backgroundfetch"
        do {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
                self.handleBackgroundTask(task: task)
            }
            
            let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 ) // Adjust the interval as needed
            
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
        let taskIdentifier = "edu.gmu.Welli-iOS.nextbackgroundtask"
        do {
            let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 ) // Adjust the interval as needed; in this case, 1 hour
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to reschedule background task: \(error)")
        }
    }
    
    func handleBackgroundFetchTask(task: BGAppRefreshTask) {
        retrieveHeartRate { result in
            switch result {
            case .success(let heartRate):
                let threshold: Double = 70 // Custom threshold value
                if heartRate > threshold {
                    self.sendHeartRateNotification(heartRate: heartRate)
                    self.storeHeartRateData(heartRate: heartRate)
                }
            case .failure(let error):
                print("Failed to retrieve heart rate: \(error)")
            }
            
            task.setTaskCompleted(success: true)
        }
    }
    
    func handleGeneralBackgroundTask() {
        // Perform general background tasks here
        retrieveHeartRate { result in
            switch result {
            case .success(let heartRate):
                let threshold: Double = 70 // Custom threshold value
                if heartRate > threshold {
                    self.sendHeartRateNotification(heartRate: Double(heartRate))
                    self.storeHeartRateData(heartRate: Double(heartRate))
                }
            case .failure(let error):
                print("Failed to retrieve heart rate: \(error)")
            }
        }
    }
    
    func retrieveHeartRate(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: .heartRate) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Heart rate data is not available."])))
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            guard let samples = samples, let mostRecentSample = samples.first as? HKQuantitySample else {
                completion(.failure(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch heart rate data."])))
                return
            }
            
            completion(.success(mostRecentSample.quantity.doubleValue(for: HKUnit(from: "count/min"))))
        }
        
        healthStore.execute(query)
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
}*/

