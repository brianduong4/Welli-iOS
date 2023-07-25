//
//  HeartRateMonitor.swift
//  Welli-iOS Watch App
//
//  Created by Brian Duong on 7/10/23.
//

import Foundation
import HealthKit
import WatchConnectivity

class HeartRateMonitor: NSObject, HKWorkoutSessionDelegate {
    
    static let shared = HeartRateMonitor()
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    
    var isMonitoring = false
    
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    var observerQuery: HKObserverQuery?
    private var isQueryInProgress = false
    static var isMonitoring = false
    
    private override init() {
        super.init()
    }
    
    func startMonitoring() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data is not available.")
            return
        }
        
        guard !isMonitoring else {
            print("Heart rate monitoring is already in progress.")
            return
        }
        
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let typesToRead: Set<HKObjectType> = [heartRateType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("Failed to authorize HealthKit access: \(error.localizedDescription)")
                return
            }
            if success {
                do {
                    self.workoutSession = try self.createWorkoutSession()
                    if let workoutSession = self.workoutSession {
                        self.healthStore.start(workoutSession)
                        self.isMonitoring = true
                    }
                } catch {
                    print("Failed to start workout session: \(error.localizedDescription)")
                }
            } else {
                print("Failed to authorize HealthKit access.")
            }
        }
    }
    
    func createWorkoutSession() throws -> HKWorkoutSession {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .unknown
        let workoutSession = try HKWorkoutSession(configuration: configuration)
        workoutSession.delegate = self
        return workoutSession
    }
    
    func stopMonitoring() {
        guard let workoutSession = workoutSession, workoutSession.state == .running else {
            print("Workout session is not available.")
            return
        }
        
        healthStore.end(workoutSession)
        isMonitoring = false
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .notStarted:
            print("Workout session has not started yet.")
        case .running:
            print("Workout session is now running.")
        case .ended:
            print("Workout session has ended.")
            self.isMonitoring = false
        default:
            print("Workout session is in an unknown state.")
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed with error: \(error.localizedDescription)")
        stopMonitoring()
    }
    
    func sendHeartRateDataToPhone(_ heartRate: Double) {
        if WCSession.default.isReachable {
            let message = ["heartRate": heartRate]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Failed to send message with heart rate data: \(error.localizedDescription)")
            }
        }
    }
    
    func heartratequery() {
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
    
    
}
