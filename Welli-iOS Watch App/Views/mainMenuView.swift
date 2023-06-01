//
//  mainMenuView.swift
//  welli Watch App
//
//

import SwiftUI
import HealthKit
import WatchConnectivity
import UserNotifications
import UIKit

//This is the main page view where you can see the main questions that leads everything else off, this is the first interface that asks about their feelings


struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    //@WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    var username = "Brian" //MARK: PUT USERNAME FOR EACH USER HERE
    
    @EnvironmentObject var environmentObject: WriteViewModel
    
    //Create instance of HKHealthStore
    let healthStore = HKHealthStore()
    
    //Define Unit
    let heartRateQuantity = HKUnit(from: "count/min")
    let heartrate = HKHeartRateMotionContext.sedentary
    
    @State var num = 0.0
    @State var scale = 1.0
    @State private var value = 0
    
    //var heartRateMonitor = HeartRateMonitor()
    
    


    

    var body: some View {
        var buttonTapped = false
        let heartrate = "\(value)"
        
        
        NavigationView()
        {
            ScrollView {
                VStack {
                    Text("How do you feel?")
                        .padding()
                }
                
                //GOOD button -> Pass to Deep Breathing Intervention viewpage
                VStack {
                    NavigationLink(destination: deepBreathingView(), label:{ Text("Good")})
                        .foregroundColor(.green)
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                                if buttonTapped == true {
                                    environmentObject.data["user"] = "\(username)"
                                    environmentObject.data["st_mood"] = "Good"
                                    environmentObject.data["intervention"] = "Breathing"
                                    environmentObject.data["hr_before"] = heartrate
                                    environmentObject.data["st_time"] = MyStruct.init().currentDate + " " + MyStruct.init().currentMilitary
                                    


                                }
                            })
                .onChange(of: environmentObject.data) {
                    newEnvironmentObject in print("State: \(newEnvironmentObject)")
                }
                
                //OKAY button -> Pass to Deep Breathing Intervention viewpage
                VStack {
                    NavigationLink(destination: deepBreathingView(), label:{ Text("Okay")
                            .foregroundColor(.blue)
                            .bold()
                    })
                }.simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["user"] = "\(username)"
                                environmentObject.data["st_mood"] = "Okay"
                                environmentObject.data["intervention"] = "Breathing"
                                environmentObject.data["hr_before"] = heartrate
                                environmentObject.data["st_time"] = MyStruct.init().currentDate + " " + MyStruct.init().currentMilitary
                                

                            }
                        })
                
                //I NEED HELP button -> Pass to multiple Intervention viewpage
                VStack {
                    NavigationLink(destination: interventionView(), label:{ Text("I Need Help")
                            .foregroundColor(.red)
                            .bold()
                    })
                }.simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["user"] = "\(username)"
                                environmentObject.data["st_mood"] = "I need help"
                                environmentObject.data["hr_before"] = heartrate
                                environmentObject.data["st_time"] = MyStruct.init().currentDate + " " + MyStruct.init().currentMilitary
                                
                            }
                        })
                /*HStack{
                    Text("\(value)")
                        .fontWeight(.regular)
                        .font(.system(size: 70))
                    
                    Text("BPM")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)
                        .padding(.bottom, 28.0)
                    Spacer()
                }
                .padding()*/
                .onAppear(perform: start) //STARTS MONITORING HEART RATE
                .onAppear {
                    if !HeartRateMonitor.isMonitoring {
                            print("Starting to monitor heart rate.")
                            HeartRateMonitor.shared.startMonitoringHeartRate()
                        }
                }
                /*.onAppear {
                    extensionDelegate.applicationDidFinishLaunching()
                }
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        // App is active (foreground)
                        break
                    case .inactive:
                        // App is inactive (background)
                        break
                    case .background:
                        // App is in the background
                        break
                    @unknown default:
                        break
                    }
                }*/
                
                
            }
        }
    }
    
    
    
    //MARK: -------------------------------------------------------------------------------------
    
    //MARK: START RECORDING HEALTH
    func start() {
        authorizeHealthkit()
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
    }

    func authorizeHealthkit() {
        // Used to define the identifiers that create quanitity type objects.
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]

        // Request permission to save and read the specified data types.
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) {
            (success, error)
            in
        }
    }

    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        // We want data points from our current device
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        
        // A query that returns changes to the HealthKit store, including a snapshot of new changes and continuous monitoring as a long-runninig query.
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            
        // A sample that represents a quantity, including the value and the units.
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            
            self.process(samples, type: quantityTypeIdentifier)
            
        }
        
        // It provides us with both the ability to receive a snapshot of data, and then on subsequeny calls, a snapshot of what has changed.
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        query.updateHandler = updateHandler
        
        // query execution
        
        healthStore.execute(query)
    }

    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        // variable initialization
        var lastHeartRate = 0.0
        
        // cycle and value assignment
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
            
            
            self.value = Int(lastHeartRate)
        }
    }
    //MARK: END RECORDING HEALTH
    
}

//MARK: -------------------------------------------------------------------------------------

class HostingController<Content>: WKHostingController<Content> where Content: View {
    override var body: Content {
        return ContentView() as! Content
    }
}

//MARK: -------------------------------------------------------------------------------------

//MARK: BEGINNING OF THRESHOLD NOTIFICATION CENTER
//MARK: SAMPLE 8

/*class HeartRateMonitor: NSObject, ObservableObject {
    static let shared = HeartRateMonitor()

    private var observerQuery: HKObserverQuery?
    private var isQueryInProgress = false

    private let healthStore = HKHealthStore()
    private let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!

    private var notificationPaused = false
    static var isNotificationPaused = false
    static var isMonitoring = false

    private var isInBackground = false

    private override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: WKExtension.applicationWillResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: WKExtension.applicationDidBecomeActiveNotification, object: nil)
    }

    @objc func appMovedToBackground() {
        print("App moved to Background!")
        self.isInBackground = true
    }

    @objc func appMovedToForeground() {
        print("App moved to Foreground!")
        self.isInBackground = false
    }

    func startMonitoringHeartRate() {
        guard !HeartRateMonitor.isMonitoring else {
            return
        }
        HeartRateMonitor.isMonitoring = true

        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }

        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
                HeartRateMonitor.isMonitoring = false
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

                    if self.isQueryInProgress || !self.isInBackground {
                        completionHandler()
                        return
                    }

                    self.isQueryInProgress = true

                    self.fetchMostRecentHeartRateSamples { heartRateSamples in
                        let highHeartRateCount = heartRateSamples.filter { sample in
                            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                            return heartRate > 60.0
                        }.count

                        if highHeartRateCount >= 3 && !self.notificationPaused {
                            self.sendHighHeartRateNotification()
                            self.pauseHighHeartRateNotifications()
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
                self.observerQuery = observerQuery
            }
        }
    }

    func fetchMostRecentHeartRateSamples(completion: @escaping ([HKQuantitySample]) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 3, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Failed to fetch heart rate samples: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            completion(samples)
        }

        healthStore.execute(query)
    }

    private func sendHighHeartRateNotification() {
        let content = UNMutableNotificationContent()
        let identifier = "Threshold-Notification"
        content.title = "High Heart Rate"
        content.body = "Your heart rate is above 70 bpm."
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 15, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    private func pauseHighHeartRateNotifications() {
        HeartRateMonitor.isNotificationPaused = true
        print("Notification paused: \(HeartRateMonitor.isNotificationPaused)")
    }
}*/


//MARK: SAMPLE 7
/*class HeartRateMonitor {
    static let shared = HeartRateMonitor()
    
    let healthStore = HKHealthStore()
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    
    var notificationPaused = false
    static var isNotificationPaused = false
    static var isMonitoring = false
    
    var timer: Timer?
    var lastSampleDate: Date?
    
    private init() {}
    
    func startMonitoringHeartRate() {
        guard !HeartRateMonitor.isMonitoring else {
            return
        }
        HeartRateMonitor.isMonitoring = true
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
                HeartRateMonitor.isMonitoring = false
                return
            }
            
            self.fetchMostRecentHeartRateSamples { heartRateSamples in
                for sample in heartRateSamples {
                    let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    print("Heart rate sample: \(heartRate) bpm")
                }
                print("-----")
                
                self.scheduleHeartRateQuery()
            }
        }
    }
    
    func fetchMostRecentHeartRateSamples(completion: @escaping ([HKQuantitySample]) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 3, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Failed to fetch heart rate samples: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            completion(samples)
        }
        
        healthStore.execute(query)
    }
    
    func scheduleHeartRateQuery() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(queryHeartRate), userInfo: nil, repeats: true)
    }
    
    @objc func queryHeartRate() {
        fetchMostRecentHeartRateSamples { [weak self] heartRateSamples in
            guard let self = self else {
                return
            }
            
            for sample in heartRateSamples {
                // Check if the sample is more recent than the last processed sample
                if let lastSampleDate = self.lastSampleDate, sample.startDate <= lastSampleDate {
                    continue
                }
                
                let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                print("Heart rate sample: \(heartRate) bpm")
                
                // Store the date of this sample
                self.lastSampleDate = sample.startDate
                
                if heartRate > 70.0 && !self.notificationPaused {
                    self.sendHighHeartRateNotification()
                    self.pauseHighHeartRateNotifications()
                }
            }
            
            print("-----")
        }
    }
    
    func sendHighHeartRateNotification() {
        // Your code for sending the high heart rate notification
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
        HeartRateMonitor.isNotificationPaused = true
        print("Notification paused: \(HeartRateMonitor.isNotificationPaused)")
        
        // Your code for pausing the high heart rate notifications
        HeartRateMonitor.isNotificationPaused = true

        // Print notification status in the console
        print("Notification paused: \(HeartRateMonitor.isNotificationPaused)")

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

//MARK: SAMPLE 6

/*class HeartRateMonitor {
    static let shared = HeartRateMonitor()

    let healthStore = HKHealthStore()
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!

    var notificationPaused = false
    static var isNotificationPaused = false
    static var isMonitoring = false
    
    var timer: Timer?
    var lastSampleDate: Date?

    private init() {}

    func startMonitoringHeartRate() {
        guard !HeartRateMonitor.isMonitoring else {
            return
        }
        HeartRateMonitor.isMonitoring = true

        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }

        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            print("Inside authorization request closure.")
            
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
                HeartRateMonitor.isMonitoring = false
                return
            }

            let predicate = HKQuery.predicateForQuantitySamples(
                with: .greaterThan,
                quantity: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 60.0)
            )

            let observerQuery = HKObserverQuery(
                sampleType: self.heartRateType,
                predicate: predicate
            ) { query, completionHandler, error in
                // Cancel the previous timer
                print("Inside observer query closure.")
                self.timer?.invalidate()
                self.timer = nil

                // Schedule the update handler to run after a delay
                self.timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { _ in
                    self.fetchMostRecentHeartRateSamples { heartRateSamples in
                        for sample in heartRateSamples {
                            // Ignore this sample if we've already processed it
                            guard self.lastSampleDate == nil || sample.startDate > self.lastSampleDate! else {
                                continue
                            }

                            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                            print("Heart rate sample: \(heartRate) bpm")

                            // Store the date of this sample
                            self.lastSampleDate = sample.startDate

                            // Check if the heart rate is higher than the threshold and the notification is not paused
                            if heartRate > 70.0 && !self.notificationPaused {
                                self.sendHighHeartRateNotification()
                                self.pauseHighHeartRateNotifications()
                            }
                        }
                        print("-----")
                    }

                    // Execute the completion handler outside the timer's block
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
        // Define the sort descriptor to get the most recent samples
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        // Create the query to fetch the most recent heart rate samples
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
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
        HeartRateMonitor.isNotificationPaused = true

        // Print notification status in the console
        print("Notification paused: \(HeartRateMonitor.isNotificationPaused)")

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
    
    func stopMonitoringHeartRate() {
        self.timer?.invalidate()
        self.timer = nil
        HeartRateMonitor.isMonitoring = false
    }
}*/

//MARK: SAMPLE 5

class HeartRateMonitor {
    
    //@WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    
    static let shared = HeartRateMonitor()
    
    var observerQuery: HKObserverQuery?
    private var isQueryInProgress = false

    let healthStore = HKHealthStore()
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!

    var notificationPaused = false
    static var isNotificationPaused = false
    static var isMonitoring = false
    
    var isInBackground = false

    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: WKExtension.applicationWillResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: WKExtension.applicationDidBecomeActiveNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
            print("App moved to Background!")
            self.isInBackground = true
        }

        @objc func appMovedToForeground() {
            print("App moved to Foreground!")
            self.isInBackground = false
        }
    

    func startMonitoringHeartRate() {
        
        guard !HeartRateMonitor.isMonitoring else {
            return
        }
        HeartRateMonitor.isMonitoring = true
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
                HeartRateMonitor.isMonitoring = false
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
                    
                    /*if self.isQueryInProgress || !self.isInBackground {  // <-- check if the app is in the background
                     completionHandler()
                     return
                     }*/
                    
                    if self.isQueryInProgress {
                        completionHandler()
                        return
                    }
                    
                    self.isQueryInProgress = true
                    
                    /*self.fetchMostRecentHeartRateSamples { heartRateSamples in
                        // Only consider samples fetched when app is in the background
                        if self.isInBackground {
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
                            }
                        }
                        
                        self.isQueryInProgress = false
                        completionHandler()
                    }
                }*/
                    
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
                        HeartRateMonitor.isMonitoring = false
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
        // Get the current date and time
        let currentDate = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentDate)
        
        // Check if the current hour is within the specified time range
        if currentHour >= 12 && currentHour < 15 {
            // Fetch the most recent heart rate samples
            fetchMostRecentHeartRateSamples { heartRateSamples in
                // Filter samples with heart rates above 80 bpm
                let heartRateThreshold: Double = 80
                let aboveThresholdSamples = heartRateSamples.filter { sample in
                    let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    return heartRate > heartRateThreshold
                }
                
                // Check if there are at least 3 samples above the threshold
                if aboveThresholdSamples.count >= 3 {
                    let content = UNMutableNotificationContent()
                    let identifier = "Threshold-Notification"
                    content.title = "High Heart Rate"
                    content.body = "Your heart rate is above 80 bpm."
                    content.sound = UNNotificationSound.default
                    content.badge = 1
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Failed to schedule notification: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    
    /*func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Check if the received notification's identifier matches the initial notification's identifier
        UNUserNotificationCenter.current().delegate = self
        if response.notification.request.identifier == "Threshold-Notification" {
            // Clear all other pending notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        completionHandler()
    }*/
    

    
    
    func pauseHighHeartRateNotifications() {
        HeartRateMonitor.isNotificationPaused = true

        // Print notification status in the console
        print("Notification paused: \(HeartRateMonitor.isNotificationPaused)")

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
}

//MARK: SAMPLE 1

/*struct HeartRateMonitor {
    let healthStore = HKHealthStore()
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    
    var notificationPaused = false
    static var isNotificationPaused = false
    
    func startMonitoringHeartRate() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        

        // Request authorization for heart rate data
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if let error = error {
                // Handle the authorization error
                print("Authorization error: \(error.localizedDescription)")
                return
            }

            // Create the predicate for heart rate samples above 120 bpm
            let predicate = HKQuery.predicateForQuantitySamples(
                with: .greaterThan,
                quantity: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 120.0)
            )

            // Create the Observer query
            let observerQuery = HKObserverQuery(
                sampleType: self.heartRateType,
                predicate: predicate
            ) { query, completionHandler, error in
                if let error = error {
                    // Handle the error appropriately
                    print("Observer query error: \(error.localizedDescription)")
                    return
                }

                // Fetch the most recent heart rate samples
                self.fetchMostRecentHeartRateSamples { heartRateSamples in
                    // Print the heart rate samples
                    for sample in heartRateSamples {
                        let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                        print("Heart rate sample: \(heartRate) bpm")
                    }
                    print("-----")

                    // Check if the condition is met for sending the notification
                    let highHeartRateCount = heartRateSamples.filter { sample in
                        let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                        return heartRate > 120.0
                    }.count

                    if highHeartRateCount >= 3 && !self.notificationPaused {
                        // Send the high heart rate notification
                        self.sendHighHeartRateNotification()
                        // Pause the notifications for 15 minutes
                        self.pauseHighHeartRateNotifications()
                    }

                    completionHandler()
                }
            }

            // Enable background delivery for the observer query
            self.healthStore.enableBackgroundDelivery(for: self.heartRateType, frequency: .immediate) { (success, error) in
                if let error = error {
                    // Handle error
                    print("Failed to enable background delivery: \(error.localizedDescription)")
                } else {
                    print("Background delivery enabled")
                }
            }

            // Register the Observer query
            self.healthStore.execute(observerQuery)
        }
    }

    func fetchMostRecentHeartRateSamples(completion: @escaping ([HKQuantitySample]) -> Void) {
        // Define the sort descriptor to get the most recent samples
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        // Create the query to fetch the most recent heart rate samples
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 5, sortDescriptors: [sortDescriptor]) { query, samples, error in
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
        content.body = "Your heart rate is above 120 bpm."
        content.sound = UNNotificationSound.default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "HeartRateNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    

    func pauseHighHeartRateNotifications() {
        HeartRateMonitor.isNotificationPaused = true
        
        // Print notification status in the console
        print("Notification paused: \(HeartRateMonitor.isNotificationPaused)")
        
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

//MARK: SAMPLE 2

/*
struct HeartRateMonitor {
    let healthStore = HKHealthStore()
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    
    var observerQuery: HKObserverQuery?
    var notificationPaused = false
    static var isNotificationPaused = false
    
    mutating func startMonitoringHeartRate() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        if observerQuery != nil {
            // Observer query is already active, no need to start a new one
            return
        }
        
        // Request authorization for heart rate data
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { [weak self] success, error in
            guard let self = self else { return }
            
            if let error = error {
                // Handle the authorization error
                print("Authorization error: \(error.localizedDescription)")
                return
            }
            
            // Create the predicate for heart rate samples above 120 bpm
            let predicate = HKQuery.predicateForQuantitySamples(
                with: .greaterThan,
                quantity: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 120.0)
            )
            
            // Create the Observer query
            let observerQuery = HKObserverQuery(
                sampleType: self.heartRateType,
                predicate: predicate,
                updateHandler: { query, completionHandler, error in
                    if let error = error {
                        // Handle the error appropriately
                        print("Observer query error: \(error.localizedDescription)")
                        completionHandler()
                        return
                    }
                    
                    // Fetch the most recent heart rate samples
                    self.fetchMostRecentHeartRateSamples { heartRateSamples in
                        // Print the heart rate samples
                        for sample in heartRateSamples {
                            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                            print("Heart rate sample: \(heartRate) bpm")
                        }
                        print("-----")
                        
                        // Check if the condition is met for sending the notification
                        let highHeartRateCount = heartRateSamples.filter { sample in
                            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                            return heartRate > 120.0
                        }.count
                        
                        if highHeartRateCount >= 3 && !self.notificationPaused {
                            // Send the high heart rate notification
                            self.sendHighHeartRateNotification()
                            // Pause the notifications for 3 hours
                            self.pauseHighHeartRateNotifications()
                        }
                        
                        self.observerQuery = query

                        
                        completionHandler()
                    }
                }
            )
            
            // Enable background delivery for the observer query
            self.healthStore.enableBackgroundDelivery(for: self.heartRateType, frequency: .immediate) { (success, error) in
                if let error = error {
                    // Handle error
                    print("Failed to enable background delivery: \(error.localizedDescription)")
                } else {
                    print("Background delivery enabled")
                }
            }
            
            // Register the Observer query
            self.healthStore.execute(observerQuery)
            
        }
    }
    
    func fetchMostRecentHeartRateSamples(completion: @escaping ([HKQuantitySample]) -> Void) {
        // Define the sort descriptor to get the most recent samples
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Create the query to fetch the most recent heart rate samples
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 5, sortDescriptors: [sortDescriptor]) { query, samples, error in
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
        content.body = "Your heart rate is above 120 bpm."
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "HeartRateNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func pauseHighHeartRateNotifications() {
        HeartRateMonitor.isNotificationPaused = true
        
        // Print notification status in the console
        print("Notification paused: \(HeartRateMonitor.isNotificationPaused)")
        
        // Schedule the resumption of notifications after 3 hours
        let resumeDate = Date().addingTimeInterval(3 * 60 * 60) // 3 hours
        
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
}
*/

//MARK: SAMPLE 3

/*struct HeartRateMonitor {
    let healthStore = HKHealthStore()
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    
    func startMonitoringHeartRate() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        // Request authorization for heart rate data
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if let error = error {
                // Handle the authorization error
                print("Authorization error: \(error.localizedDescription)")
                return
            }
            
            // Create the predicate for heart rate samples above 120 bpm
            let predicate = HKQuery.predicateForQuantitySamples(
                with: .greaterThan,
                quantity: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 120.0)
            )
            
            // Create the Observer query
            let observerQuery = HKObserverQuery(
                sampleType: self.heartRateType,
                predicate: predicate
            ) { query, completionHandler, error in
                if let error = error {
                    // Handle the error appropriately
                    print("Observer query error: \(error.localizedDescription)")
                    return
                }
                
                // Fetch the most recent heart rate samples
                self.fetchMostRecentHeartRateSamples { heartRateSamples in
                    // Print the heart rate samples
                    for sample in heartRateSamples {
                        let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                        print("Heart rate sample: \(heartRate) bpm")
                    }
                    
                    // Perform necessary actions based on the heart rate updates
                    // For example, send a notification, update UI, etc.
                    // Create a notification content
                    let content = UNMutableNotificationContent()
                    content.title = "High Heart Rate"
                    content.body = "Your heart rate is above 120 bpm."
                    content.sound = UNNotificationSound.default // Set the notification sound
                    content.badge = 1 // Ensure badge is displayed
                    
                    // Create a notification trigger
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    
                    // Create a notification request
                    let request = UNNotificationRequest(identifier: "HeartRateNotification", content: content, trigger: trigger)
                    
                    // Add the notification request to the notification center
                    UNUserNotificationCenter.current().add(request)
                    
                    // Call the completion handler to indicate the query has been processed
                    completionHandler()
                }
            }
            
            // Enable background delivery for the observer query
            self.healthStore.enableBackgroundDelivery(for: self.heartRateType, frequency: .immediate) { (success, error) in
                if let error = error {
                    // Handle error
                    print("Failed to enable background delivery: \(error.localizedDescription)")
                } else {
                    print("Background delivery enabled")
                }
            }
            
            // Register the Observer query
            self.healthStore.execute(observerQuery)
        }
    }
    
    func fetchMostRecentHeartRateSamples(completion: @escaping ([HKQuantitySample]) -> Void) {
        // Define the sort descriptor to get the most recent samples
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        // Create the query to fetch the most recent heart rate samples
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 5, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Failed to fetch heart rate samples: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            // Perform the threshold comparison for each sample
            var highHeartRateCount = 0
            for sample in samples {
                let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                print("Heart rate sample: \(heartRate) bpm")

                // Perform the threshold comparison here
                if heartRate > 120.0 {
                    highHeartRateCount += 1
                }
            }

            // Check if the high heart rate count exceeds the predefined threshold count
            if highHeartRateCount >= 3 {
                // Perform necessary actions based on the heart rate breach
                // For example, send a notification, update UI, etc.
                let content = UNMutableNotificationContent()
                content.title = "High Heart Rate"
                content.body = "Your heart rate is above 120 bpm."
                content.sound = UNNotificationSound.default
                content.badge = 1

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: "HeartRateNotification", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }

            completion(samples)
        }

        // Execute the query
        healthStore.execute(query)
    }
}*/

//MARK: SAMPLE 4

/*
class HeartRateMonitor {
    let healthStore = HKHealthStore()
    var notificationTimer: Timer?
    var isFirstNotificationSent = false
    
    func requestAuthorization() {
        // Request authorization to read heart rate data
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { (success, error) in
            if success {
                // Authorization granted, start monitoring heart rate
                self.startMonitoringHeartRate()
            } else {
                // Authorization denied or error occurred
                print("Authorization failed for heart rate data")
            }
        }
    }
    
    func startMonitoringHeartRate() {
        // Define the heart rate type and predicate
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: nil, options: .strictEndDate)
        let currentTime = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a" // Set the desired time format



        // Convert the current time to a formatted string
        let formattedTime = dateFormatter.string(from: currentTime)
        
        // Create the observer query
        let observerQuery = HKObserverQuery(sampleType: heartRateType, predicate: predicate) { (query, completionHandler, error) in
            if let error = error {
                // Handle error
                print("Observer query failed with error: \(error.localizedDescription)")
                return
            }
            
            // Fetch the most recent heart rate sample
            self.fetchMostRecentHeartRateSample { (heartRate) in
                // Check if heart rate exceeds threshold
                if heartRate > 120 {
                    if !self.isFirstNotificationSent {
                        // Send the first notification
                        self.sendHeartRateNotification()
                        self.isFirstNotificationSent = true
                    } else {
                        // Schedule the next delayed notification
                        self.scheduleDelayedNotification()
                    }
                }
                
                // Print the most recent heart rate
                print("Most recent heart rate: \(heartRate) bpm: \(formattedTime)")
                
            }
            
            // Call the completion handler to indicate query completion
            completionHandler()
        }
        
        // Execute the observer query
        healthStore.execute(observerQuery)
        
        // Enable background delivery for the observer query
                healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { (success, error) in
                    if let error = error {
                        // Handle error
                        print("Failed to enable background delivery: \(error.localizedDescription)")
                    } else {
                        print("Background delivery enabled")
                    }
                }
    }
    
    func fetchMostRecentHeartRateSample(completion: @escaping (Double) -> Void) {
        // Define the heart rate type and sort descriptor
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Create the query to fetch the most recent heart rate sample
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let error = error {
                // Handle error
                print("Heart rate query failed with error: \(error.localizedDescription)")
                return
            }
            
            // Get the most recent heart rate sample
            if let heartRateSample = samples?.first as? HKQuantitySample {
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRate = heartRateSample.quantity.doubleValue(for: heartRateUnit)
                
                // Call the completion handler with the heart rate value
                completion(heartRate)
            } else {
                // No heart rate sample found
                completion(0)
            }
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    func scheduleDelayedNotification() {
        // Cancel any existing timer
        notificationTimer?.invalidate()
        
        // Schedule a timer to send the next notification after 3 hours
        notificationTimer = Timer.scheduledTimer(withTimeInterval: 10800, repeats: false) { (_) in
            self.sendHeartRateNotification()
        }
    }
    
    func sendHeartRateNotification() {
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "High Heart Rate"
        content.body = "Your heart rate is above 120 bpm."
        content.sound = .default
        content.badge = 1
        
        // Create the notification request
        let request = UNNotificationRequest(identifier: "HeartRateNotification", content: content, trigger: nil)
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                // Handle error
                print("Failed to add notification request: \(error.localizedDescription)")
            }
        }
    }
}*/

//MARK: END OF THRESHOLD NOTIFICATION CENTER

struct mainMenuView_Previews: PreviewProvider {
    static let environmentObject = WriteViewModel()
    
    static var previews: some View {
        ContentView().environmentObject(environmentObject)
    }
}

