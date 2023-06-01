//
//  ThresholdManager.swift
//  Welli-iOS Watch App
//
//  Created by Brian Duong on 5/30/23.
//

import Foundation
import HealthKit

class HeartRateManager {
    static let shared = HeartRateManager()
    private let healthStore = HKHealthStore()

    private init() { }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { (success, error) in
            completion(success)
        }
    }
    
    func startMonitoringHeartRate() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { (success, error) in
            if success {
                print("Background delivery enabled for heart rate")
                let heartRateObserverQuery = HKObserverQuery(sampleType: heartRateType, predicate: nil) { (query, completion, error) in
                    if let error = error {
                        print("Observer query failed: \(error.localizedDescription)")
                        return
                    }
                    
                    // Handle the new heart rate data, for example by fetching the most recent samples
                }
                
                self.healthStore.execute(heartRateObserverQuery)
            } else if let error = error {
                print("Failed to enable background delivery for heart rate: \(error.localizedDescription)")
            }
        }
    }
}
