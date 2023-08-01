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
    
    var username = "Test" //MARK: PUT USERNAME FOR EACH USER HERE
    
    @EnvironmentObject var environmentObject: WriteViewModel
    
    //Create instance of HKHealthStore
    let healthStore = HKHealthStore()
    
    //Define Unit
    let heartRateQuantity = HKUnit(from: "count/min")
    let heartrate = HKHeartRateMotionContext.sedentary
    
    @State var num = 0.0
    @State var scale = 1.0
    @State private var value = 0
    

    

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
                    if !HeartRateMonitor
                        .isMonitoring {
                            print("Starting to monitor heart rate.")
                            HeartRateMonitor.shared.startMonitoringHeartRate()
                        }
                }
                
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

/*class HeartRateMonitor {
    
    static let shared = HeartRateMonitor()
    
    //var notificationSent = false // Declare notificationSent as an instance variable
    
    var observerQuery: HKObserverQuery?
    private var isQueryInProgress = false
    
    let healthStore = HKHealthStore()
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    
    var notificationPaused = false
    static var isNotificationPaused = false
    static var isMonitoring = false
    
    var isInBackground = false
    var heartRateSamples: [HKQuantitySample] = [] // Declare heartRateSamples as an instance variable
    
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
                        
                        if highHeartRateCount >= 3 {
                            self.sendHighHeartRateNotification()
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
            
            // Filter out duplicate samples based on heart rate values
            var uniqueSamples: [HKQuantitySample] = []
            var uniqueHeartRates: Set<Double> = []
            
            for sample in samples {
                let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                if !uniqueHeartRates.contains(heartRate) {
                    uniqueHeartRates.insert(heartRate)
                    uniqueSamples.append(sample)
                }
            }
            
            completion(uniqueSamples)
            
            //completion(samples)
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    func sendHighHeartRateNotification() {
        
        let username = "Ben"
        
        // Get the current date and time
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let currentTime = dateFormatter.string(from: currentDate)
        
        // Get the current date and time
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentDate)
        
        // Check if the current hour is within the specified time range
        if currentHour >= 9 && currentHour < 12 {                                                           //MARK: FIRST INTERVAL
            
            
            //let heartRateThreshold: Double = 120 //CAITLIN's
            //let heartRateThreshold: Double = 89 //ERIN's
            //let heartRateThreshold: Double = 120 //LAUREN's
            //let heartRateThreshold: Double = 117 //COLIN's
            //let heartRateThreshold: Double = 112 //MCKENNA's
            let heartRateThreshold: Double = 115 //BEN's
            
            // Fetch the most recent heart rate samples
            fetchMostRecentHeartRateSamples { heartRateSamples in
                
                // Filter samples with heart rates above 80 bpm
                
                let aboveThresholdSamples = heartRateSamples.filter { sample in // Access the heartRateSamples instance variable
                    let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    return heartRate > heartRateThreshold
                }
                
                print("Total heart rate samples: \(heartRateSamples.count)")
                print("Samples above threshold: \(aboveThresholdSamples.count)")
                
                
                
                // Check if there are at least 3 samples above the threshold
                if aboveThresholdSamples.count >= 3 {
                    print("SAMPLES PAST CONDITIONS, SENDING TO FIREBASE")
                    // Fetch the most recent heart rate sample
                    guard let mostRecentSample = heartRateSamples.first else {
                        print("No heart rate samples available.")
                        return
                    }
                    
                    
                    // Extract the heart rate value from the sample
                    let heartRate = mostRecentSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    
                    // Create the message to be sent to the iPhone app
                    let message: [String: Any] = [
                        "user": "\(username)",
                        "type": "threshold",
                        "time": currentTime,
                        "heartRate": heartRate
                    ]
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        [weak self] in
                        
                        guard self != nil else {
                            return //check if self still exists
                        }
                        
                        
                        let session = WCSession.default
                        if session.isReachable {
                            print("iOS connection reachable")
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
                    
                    let content = UNMutableNotificationContent()
                    let identifier = "Threshold-Notification"
                    content.title = "Hi \(username), how do you feel?"
                    content.body = "How do you feel? Open the app to check in."
                    content.sound = UNNotificationSound.default
                    content.badge = 1
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Failed to schedule notification: \(error.localizedDescription)")
                        }
                    }
                } else if currentHour >= 12 && currentHour < 15 {                                                           //MARK: SECOND INTERVAL
                    
                    //let heartRateThreshold: Double = 93 //CAITLIN's
                    //let heartRateThreshold: Double = 93 //ERIN's
                    //let heartRateThreshold: Double = 123 //LAUREN's
                    //let heartRateThreshold: Double = 120 //COLIN's
                    //let heartRateThreshold: Double = 106 //MCKENNA's
                    let heartRateThreshold: Double = 115 //BEN's
                    
                    // Fetch the most recent heart rate samples
                    self.fetchMostRecentHeartRateSamples { heartRateSamples in
                        
                        // Filter samples with heart rates above 80 bpm
                        
                        let aboveThresholdSamples = heartRateSamples.filter { sample in // Access the heartRateSamples instance variable
                            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                            return heartRate > heartRateThreshold
                        }
                        
                        print("Total heart rate samples: \(heartRateSamples.count)")
                        print("Samples above threshold: \(aboveThresholdSamples.count)")
                        
                        
                        
                        // Check if there are at least 3 samples above the threshold
                        if aboveThresholdSamples.count >= 3 {
                            print("SAMPLES PAST CONDITIONS, SENDING TO FIREBASE")
                            // Fetch the most recent heart rate sample
                            guard let mostRecentSample = heartRateSamples.first else {
                                print("No heart rate samples available.")
                                return
                            }
                            
                            
                            // Extract the heart rate value from the sample
                            let heartRate = mostRecentSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                            
                            // Create the message to be sent to the iPhone app
                            let message: [String: Any] = [
                                "user": "\(username)",
                                "type": "threshold",
                                "time": currentTime,
                                "heartRate": heartRate
                            ]
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                [weak self] in
                                
                                guard self != nil else {
                                    return //check if self still exists
                                }
                                
                                
                                let session = WCSession.default
                                if session.isReachable {
                                    print("iOS connection reachable")
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
                            
                            let content = UNMutableNotificationContent()
                            let identifier = "Threshold-Notification"
                            content.title = "Hi \(username), how do you feel?"
                            content.body = "How do you feel? Open the app to check in."
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
                } else if currentHour >= 15 && currentHour < 18 {                                                           //MARK: THIRD INTERVAL
                    
                    //let heartRateThreshold: Double = 107 //CAITLIN's
                    //let heartRateThreshold: Double = 83//ERIN's
                    //let heartRateThreshold: Double = 118 //LAUREN's
                    //let heartRateThreshold: Double = 115 //COLIN's
                    //let heartRateThreshold: Double = 109 //MCKENNA's
                    let heartRateThreshold: Double = 115 //BEN's
                    
                    // Fetch the most recent heart rate samples
                    self.fetchMostRecentHeartRateSamples { heartRateSamples in
                        
                        // Filter samples with heart rates above 80 bpm
                        
                        let aboveThresholdSamples = heartRateSamples.filter { sample in // Access the heartRateSamples instance variable
                            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                            return heartRate > heartRateThreshold
                        }
                        
                        print("Total heart rate samples: \(heartRateSamples.count)")
                        print("Samples above threshold: \(aboveThresholdSamples.count)")
                        
                        
                        
                        // Check if there are at least 3 samples above the threshold
                        if aboveThresholdSamples.count >= 3 {
                            print("SAMPLES PAST CONDITIONS, SENDING TO FIREBASE")
                            // Fetch the most recent heart rate sample
                            guard let mostRecentSample = heartRateSamples.first else {
                                print("No heart rate samples available.")
                                return
                            }
                            
                            
                            // Extract the heart rate value from the sample
                            let heartRate = mostRecentSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                            
                            // Create the message to be sent to the iPhone app
                            let message: [String: Any] = [
                                "user": "\(username)",
                                "type": "threshold",
                                "time": currentTime,
                                "heartRate": heartRate
                            ]
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                [weak self] in
                                
                                guard self != nil else {
                                    return //check if self still exists
                                }
                                
                                
                                let session = WCSession.default
                                if session.isReachable {
                                    print("iOS connection reachable")
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
                            
                            let content = UNMutableNotificationContent()
                            let identifier = "Threshold-Notification"
                            content.title = "Hi \(username), how do you feel?"
                            content.body = "How do you feel? Open the app to check in."
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
                } else if currentHour >= 18 && currentHour < 22 {                                                           //MARK: FOURTH INTERVAL
                    
                    //let heartRateThreshold: Double = 120 //CAITLIN's
                    //let heartRateThreshold: Double = 74 //ERIN's
                    //let heartRateThreshold: Double = 116 //LAUREN's
                    //let heartRateThreshold: Double = 99 //COLIN's
                    //let heartRateThreshold: Double = 94 //MCKENNA's
                    let heartRateThreshold: Double = 115 //BEN's
                    
                    // Fetch the most recent heart rate samples
                    self.fetchMostRecentHeartRateSamples { heartRateSamples in
                        
                        // Filter samples with heart rates above 80 bpm
                        
                        let aboveThresholdSamples = heartRateSamples.filter { sample in // Access the heartRateSamples instance variable
                            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                            return heartRate > heartRateThreshold
                        }
                        
                        print("Total heart rate samples: \(heartRateSamples.count)")
                        print("Samples above threshold: \(aboveThresholdSamples.count)")
                        
                        
                        
                        // Check if there are at least 3 samples above the threshold
                        if aboveThresholdSamples.count >= 3 {
                            print("SAMPLES PAST CONDITIONS, SENDING TO FIREBASE")
                            // Fetch the most recent heart rate sample
                            guard let mostRecentSample = heartRateSamples.first else {
                                print("No heart rate samples available.")
                                return
                            }
                            
                            
                            // Extract the heart rate value from the sample
                            let heartRate = mostRecentSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                            
                            // Create the message to be sent to the iPhone app
                            let message: [String: Any] = [
                                "user": "\(username)",
                                "type": "threshold",
                                "time": currentTime,
                                "heartRate": heartRate
                            ]
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                [weak self] in
                                
                                guard self != nil else {
                                    return //check if self still exists
                                }
                                
                                
                                let session = WCSession.default
                                if session.isReachable {
                                    print("iOS connection reachable")
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
                            
                            let content = UNMutableNotificationContent()
                            let identifier = "Threshold-Notification"
                            content.title = "Hi \(username), how do you feel?"
                            content.body = "How do you feel? Open the app to check in."
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
                        
                func checkPendingNotifications() {
                    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                        for request in requests {
                            print("Pending notification: \(request)")
                        }
                    }
                }
                        
                    
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
