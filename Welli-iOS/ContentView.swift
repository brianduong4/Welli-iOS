//
//  ContentView.swift
//  Welli-iOS
//
//  Created by Brian Duong on 4/4/23.
//

import SwiftUI
import WatchConnectivity
import UIKit
import UserNotifications
import HealthKit
import HealthKitUI
import BackgroundTasks
import Firebase
import FirebaseDatabase


struct ContentView: View {
    
    var model = ViewModelPhone()
    @State var reachable = "No"
    @State private var isHealthKitAuthorized = false
    @State private var isNotificationAuthorized = false
    let username = ""  //MARK: CHANGE USERNAME         <-----
        

    var body: some View {
        VStack {
            Image(systemName: "wifi")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Welli-iOS Companion App")
            /*Text("Firebase Connection")
                .onAppear {
                    requestHealthKitAuthorization()
                    scheduleBackgroundTask()
                    startHeartRateTracking()
                    requestNotificationAuthorization()
                }*/
            //MARK: REACH FIREBASE CONNECT
            Text("Reachable: \(reachable)")
            Button(action: {
                if self.model.session.isReachable{
                    self.reachable = "Yes"
                }
                else{
                    self.reachable = "No"
                }
                
            }) {
                Text("Update")
            }
            //MARK: END OF FIREBASE CONNECT
            
            Button("Request Permission") {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
                    success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
            
            /*Button("Upload data to Firebase") {
                uploadDataToFirebase()
            }*/
            
        }
        .padding()
    }
    
    /*func requestHealthKitAuthorization() {
            let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
            HKHealthStore().requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                if success {
                    isHealthKitAuthorized = true
                } else {
                    print("Failed to authorize HealthKit access: \(error?.localizedDescription ?? "")")
                }
            }
        }
    func requestNotificationAuthorization() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                if success {
                    isNotificationAuthorized = true
                } else {
                    print("Failed to authorize notification access: \(error?.localizedDescription ?? "")")
                }
            }
        }
        
        func scheduleBackgroundTask() {
            let taskIdentifier = "edu.gmu.Welli-iOS.backgroundfetch"
            do {
                BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
                    handleBackgroundTask(task: task)
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
        
        func handleBackgroundFetchTask(task: BGAppRefreshTask) {
            if isHealthKitAuthorized {
                retrieveHeartRate { result in
                    switch result {
                    case .success(let heartRate):
                        let threshold = 70 // MARK: CUSTOM THRESHOLD
                        if heartRate > threshold {
                            sendHeartRateNotification(heartRate: heartRate)
                            storeHeartRateData(heartRate: heartRate)
                        }
                    case .failure(let error):
                        print("Failed to retrieve heart rate: \(error)")
                    }
                    
                    task.setTaskCompleted(success: true)
                }
            } else {
                print("HealthKit access not authorized.")
                task.setTaskCompleted(success: false)
            }
        }
        
        func handleGeneralBackgroundTask() {
            // Perform general background tasks here
            // ...
        }
        
        func retrieveHeartRate(completion: @escaping (Result<Int, Error>) -> Void) {
            guard let sampleType = HKSampleType.quantityType(forIdentifier: .heartRate) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Heart rate data is not available."])))
                return
            }
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (_, results, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let heartRateSample = results?.first as? HKQuantitySample else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No heart rate data available."])))
                    return
                }
                
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRateValue = Int(heartRateSample.quantity.doubleValue(for: heartRateUnit))
                
                completion(.success(heartRateValue))
            }
            
            HKHealthStore().execute(query)
        }
        
        func sendHeartRateNotification(heartRate: Int) {
            let content = UNMutableNotificationContent()
            content.title = "High Heart Rate Detected"
            content.body = "Your heart rate is \(heartRate) bpm, which is above the threshold."
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to send notification: \(error)")
                }
            }
        }
        
        func storeHeartRateData(heartRate: Int) {
            let heartRateData: [String: Any] = ["heartRate": heartRate, "date": Date()]
            
            var storedData: [[String: Any]] = UserDefaults.standard.array(forKey: "heartRateData") as? [[String: Any]] ?? []
            storedData.append(heartRateData)
            UserDefaults.standard.set(storedData, forKey: "heartRateData")
        }
        
        func scheduleNextBackgroundTask() {
            let taskIdentifier = "edu.gmu.Welli-iOS.backgroundfetch"
            
            let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 30) // Adjust the interval as needed
            
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("Failed to schedule next background task: \(error)")
            }
        }
        
        func startHeartRateTracking() {
            // Start heart rate tracking or other necessary background operations
            // ...
        }
    
    //MARK: UPLOAD Datasets to firebase
        func uploadDataToFirebase() {
            // Retrieve the data from UserDefaults
            guard let storedData = UserDefaults.standard.array(forKey: "heartRateData") as? [[String: Any]] else {
                return
            }

            // Create a DatabaseReference
            let ref = Database.database().reference()

            // Iterate through each stored data entry and upload it to FirebaseDatabase
            for data in storedData {
                ref.child("NotificationLog").child("\(username)").childByAutoId().setValue(data) { (error, _) in
                    if let error = error {
                        print("Failed to upload data to FirebaseDatabase: \(error)")
                    } else {
                        print("Data uploaded successfully")
                    }
                }
            }

            // Clear the stored data in UserDefaults
            UserDefaults.standard.removeObject(forKey: "heartRateData")
        }*/

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
