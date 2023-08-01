import Foundation
import HealthKit
import WatchConnectivity
import WatchKit

class HeartRateMonitor {

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
    
    func sendHeartRateDataToPhone(_ heartRate: Double) {
        if WCSession.default.isReachable {
            let message = ["heartRate": heartRate]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
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

            let observerQuery = HKObserverQuery(
                sampleType: self.heartRateType,
                predicate: nil
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
                    // Extract the heart rate value from the samples
                    let heartRates = heartRateSamples.map { sample in
                        sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    }
                    
                    // Send the heart rates to the paired iPhone app
                    let message: [String: Any] = ["heartRate": heartRates]
                    if WCSession.default.isReachable {
                        WCSession.default.sendMessage(message, replyHandler: nil) { error in
                            print("Failed to send message to iPhone app: \(error.localizedDescription)")
                        }
                    } else {
                        print("Paired device is not reachable")
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
        }

        // Execute the query
        healthStore.execute(query)
    }
}
