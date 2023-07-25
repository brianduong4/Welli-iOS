import Foundation
import UserNotifications
import HealthKit
import WatchConnectivity

class HeartRateMonitor: NSObject, HKWorkoutSessionDelegate {
    
    static let shared = HeartRateMonitor()
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    
    var isMonitoring = false
    
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
}
    
    
    // Request authorization when the application becomes active.


