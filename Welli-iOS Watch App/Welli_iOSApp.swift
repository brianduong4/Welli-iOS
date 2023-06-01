//
//  Welli_iOSApp.swift
//  Welli-iOS Watch App
//
//  Created by Brian Duong on 4/4/23.
//
//MARK: THIS IS THE MAIN CONTROL POINT OF THE APP UPON LAUNCH


import SwiftUI
import WatchKit
import UserNotifications
import WatchConnectivity
import HealthKit
import UIKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {
    
    func applicationDidFinishLaunching() {
        // Set the delegate for UNUserNotificationCenter
        UNUserNotificationCenter.current().delegate = self
        
        // Request user authorization for notifications
        let options: UNAuthorizationOptions = [.alert, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if let error = error {
                print("Failed to request authorization for notifications: \(error.localizedDescription)")
            }
        }
        
        // Other app initialization code...
    }
    
    // Handle user notification interactions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received notification response: \(response)")
        
        if response.notification.request.identifier == "Threshold-Notification" {
            print("Matching notification identifier found")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        
        completionHandler()
    }

    // Other delegate methods...
    
}




@main
struct Welli_iOS_Watch_AppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    //@WKExtensionDelegateAdaptor(AppDelegate.self) var appDelegate
    
    //@StateObject private var heartRateMonitor = HeartRateMonitor()
    
    @StateObject var environmentObject = WriteViewModel()

    
   // @StateObject private var heartRateChecker = HeartRateChecker()
    
    /*init() {
            let defaults = UserDefaults.standard
            if !defaults.bool(forKey: "didScheduleNotifications") {
                NotificationManager.scheduleNotifications()
                defaults.set(false, forKey: "didScheduleNotifications")
            }
        }*/
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(environmentObject).onAppear {
                if WCSession.isSupported() {
                    WCSession.default.activate()
                }
            }
            
        }
        /*.onChange(of: scenePhase) { phase in
            switch phase {
            case: .active
                //heartRateMonitor.stopMonitoringHeartRate()
            case: .inactive, .background
                //heartRateMonitor.startMonitoringHeartRate()
            @unknown default:
                break
            }
        }*/
    }
}



/*class HeartRateMonitor: ObservableObject {
    
    
    //private let healthStore = HKHealthStore()
    var observerQuery: HKObserverQuery?
    private var isQueryInProgress = false
    
    let healthStore = HKHealthStore()
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    
    var notificationPaused = false
    static var isNotificationPaused = false
    static var isMonitoring = false
    
    var isActive = false
    
    func startMonitoringHeartRate() {
        isActive = true
        // Start your observer query or timer here
    }
    
    func stopMonitoringHeartRate() {
        isActive = false
        // Stop your observer query or timer here
    }
    
    // Function to authorize HealthKit
    func authorizeHealthKit() {
        let healthKitTypes: Set = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { success, error in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    // Function to fetch heart rate data
    func fetchHeartRateData() {
        // Only fetch if isActive is true
        guard isActive else { return }
        
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            // Handle your samples here
        }
        
        healthStore.execute(query)
    }
    
    
    func queryNotification() {
        // Only fetch if isActive is true
        guard isActive else { return }
        
        let predicate = HKQuery.predicateForQuantitySamples(
            with: .greaterThan,
            quantity: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 70.0)
        )
        
        if self.observerQuery == nil {
            let observerQuery = HKObserverQuery(
                sampleType: self.heartRateType,
                predicate: predicate
            ) { query, completionHandler, error in
                if let error = error {
                    print("Observer query error: \(error.localizedDescription)")
                    completionHandler()
                    return
                }
                
                if self.isQueryInProgress {
                    completionHandler()
                    return
                }
                
                self.isQueryInProgress = true
                
                self.fetchMostRecentHeartRateSamples { heartRateSamples in
                    for sample in heartRateSamples {
                        let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                        print("Heart rate sample: \(heartRate) bpm")
                    }
                    print("-----")
                    
                    let highHeartRateCount = heartRateSamples.filter { sample in
                        let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                        return heartRate > 60.0
                    }.count
                    
                    if highHeartRateCount >= 3 && !self.notificationPaused {
                        self.sendHighHeartRateNotification()
                        //pauseHighHeartRateNotifications()
                        
                        // Get the current time and date
                        let currentDate = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .short
                        let currentTime = dateFormatter.string(from: currentDate)
                        
                        // Fetch the most recent heart rate sample
                        self.fetchMostRecentHeartRateSamples { heartRateSamples in
                            guard let mostRecentSample = heartRateSamples.first else {
                                print("No heart rate samples available.")
                                return
                            }
                            
                            // Extract the heart rate value from the sample
                            let heartRate = mostRecentSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                            
                            // Create the message to be sent to the iPhone app
                            let message: [String: Any] = [
                                "user": "Brian",
                                "type": "threshold",
                                "time": currentTime,
                                "heartRate": heartRate
                            ]
                            
                            let session = WCSession.default
                            if session.isReachable {
                                print("ios connection reachable")
                                print("Sending dictionary: \(message)")
                                session.sendMessage(message, replyHandler: nil, errorHandler: nil)
                            }
                            
                            // Send the message to the paired iPhone app
                            if WCSession.default.isReachable {
                                WCSession.default.sendMessage(message, replyHandler: nil) { error in
                                    print("Failed to send message to iPhone app: \(error.localizedDescription)")
                                }
                            } else {
                                print("Paired device is not reachable")
                                let error = WCError(WCError.Code.notReachable)
                                print("Failed to send message to iPhone app: \(error.localizedDescription)")
                            }
                        }
                        //environmentObject.notificationData["HeartRate"] = heartrate
                        //environmentObject.notificationData["Time"] = MyStruct.init().currentDate + " " + MyStruct.init().currentMilitary
                    }
                    self.isQueryInProgress = false
                    completionHandler()
                }
            }
            
            
            self.healthStore.enableBackgroundDelivery(for: self.heartRateType, frequency: .immediate) { (success, error) in
                if let error = error {
                    print("Failed to enable background delivery: \(error.localizedDescription)")
                    HeartRateMonitor.isMonitoring = false
                } else {
                    print("Background delivery enabled")
                }
            }
            
            self.healthStore.execute(observerQuery)
        }
    }
    
    
    
    func fetchMostRecentHeartRateSamples(completion: @escaping ([HKQuantitySample]) -> Void) {
        // Only fetch if isActive is true
        guard isActive else { return }
        
        // Define the sort descriptor to get the most recent samples
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        // Create the query to fetch the most recent heart rate samples
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 3, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Failed to fetch heart rate samples: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            completion(samples)
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    func sendHighHeartRateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "High Heart Rate"
        content.body = "Your heart rate is above 70 bpm."
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "HeartRateNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
    }
}*/



/*class ThresholdMonitor {
    static let shared = ThresholdMonitor()
    
    var observerQuery: HKObserverQuery?
    private var isQueryInProgress = false

    let healthStore = HKHealthStore()
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!

    var notificationPaused = false
    static var isNotificationPaused = false
    static var isMonitoring = false

    private init() {}

    func startMonitoringHeartRate() {
        
        guard !ThresholdMonitor.isMonitoring else {
            return
        }
        ThresholdMonitor.isMonitoring = true
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
                ThresholdMonitor.isMonitoring = false
                return
            }
            
            let predicate = HKQuery.predicateForQuantitySamples(
                with: .greaterThan,
                quantity: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 70.0)
            )
            
            if self.observerQuery == nil {
                let observerQuery = HKObserverQuery(
                    sampleType: self.heartRateType,
                    predicate: predicate
                ) { query, completionHandler, error in
                    if let error = error {
                        print("Observer query error: \(error.localizedDescription)")
                        completionHandler()
                        return
                    }
                    
                    if self.isQueryInProgress {
                        completionHandler()
                        return
                    }
                                    
                    self.isQueryInProgress = true
                    
                    self.fetchMostRecentHeartRateSamples { heartRateSamples in
                        for sample in heartRateSamples {
                            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                            print("Heart rate sample: \(heartRate) bpm")
                        }
                        print("-----")
                        
                        let highHeartRateCount = heartRateSamples.filter { sample in
                            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                            return heartRate > 60.0
                        }.count
                        
                        if highHeartRateCount >= 3 && !self.notificationPaused {
                            self.sendHighHeartRateNotification()
                            self.pauseHighHeartRateNotifications()
                            
                            // Get the current time and date
                            let currentDate = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateStyle = .medium
                            dateFormatter.timeStyle = .short
                            let currentTime = dateFormatter.string(from: currentDate)
                            
                            // Fetch the most recent heart rate sample
                            self.fetchMostRecentHeartRateSamples { heartRateSamples in
                                guard let mostRecentSample = heartRateSamples.first else {
                                    print("No heart rate samples available.")
                                    return
                                }
                                
                                // Extract the heart rate value from the sample
                                let heartRate = mostRecentSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                                
                                // Create the message to be sent to the iPhone app
                                let message: [String: Any] = [
                                    "user": "Brian",
                                    "type": "threshold",
                                    "time": currentTime,
                                    "heartRate": heartRate
                                ]
                                
                                let session = WCSession.default
                                if session.isReachable {
                                    print("ios connection reachable")
                                    print("Sending dictionary: \(message)")
                                    session.sendMessage(message, replyHandler: nil, errorHandler: nil)
                                }
                                
                                // Send the message to the paired iPhone app
                                if WCSession.default.isReachable {
                                    WCSession.default.sendMessage(message, replyHandler: nil) { error in
                                        print("Failed to send message to iPhone app: \(error.localizedDescription)")
                                    }
                                } else {
                                    print("Paired device is not reachable")
                                    let error = WCError(WCError.Code.notReachable)
                                    print("Failed to send message to iPhone app: \(error.localizedDescription)")
                                }
                            }
                            //environmentObject.notificationData["HeartRate"] = heartrate
                            //environmentObject.notificationData["Time"] = MyStruct.init().currentDate + " " + MyStruct.init().currentMilitary
                        }
                        self.isQueryInProgress = false
                        completionHandler()
                    }
                }
                
                
                self.healthStore.enableBackgroundDelivery(for: self.heartRateType, frequency: .immediate) { (success, error) in
                    if let error = error {
                        print("Failed to enable background delivery: \(error.localizedDescription)")
                        ThresholdMonitor.isMonitoring = false
                    } else {
                        print("Background delivery enabled")
                    }
                }
                
                self.healthStore.execute(observerQuery)
            }
        }
    }

    func fetchMostRecentHeartRateSamples(completion: @escaping ([HKQuantitySample]) -> Void) {

        // Define the sort descriptor to get the most recent samples
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        // Create the query to fetch the most recent heart rate samples
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 3, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Failed to fetch heart rate samples: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            completion(samples)
        }

        // Execute the query
        healthStore.execute(query)
    }

    func sendHighHeartRateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "High Heart Rate"
        content.body = "Your heart rate is above 70 bpm."
        content.sound = UNNotificationSound.default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "HeartRateNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    

    
    
    func pauseHighHeartRateNotifications() {
        ThresholdMonitor.isNotificationPaused = true

        // Print notification status in the console
        print("Notification paused: \(ThresholdMonitor.isNotificationPaused)")

        // Schedule the resumption of notifications after 15 minutes
        let resumeDate = Date().addingTimeInterval(15 * 60) // 15 minutes

        let content = UNMutableNotificationContent()
        content.title = "High Heart Rate Notification Resumed"
        content.body = "Your heart rate notifications have been resumed."
        content.sound = UNNotificationSound.default

        let resumeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: resumeDate.timeIntervalSinceNow, repeats: false)
        let resumeRequest = UNNotificationRequest(identifier: "ResumeNotification", content: content, trigger: resumeTrigger)

        UNUserNotificationCenter.current().add(resumeRequest) { error in
            if let error = error {
                print("Failed to schedule resume notification: \(error.localizedDescription)")
            }
        }
    }
}*/
