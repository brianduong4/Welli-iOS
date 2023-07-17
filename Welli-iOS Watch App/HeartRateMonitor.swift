//
//  HeartRateMonitor.swift
//  Welli-iOS Watch App
//
//  Created by Brian Duong on 7/10/23.
//

import Foundation
import HealthKit
import WatchConnectivity

class HeartRateMonitor: NSObject, HKWorkoutSessionDelegate, WCSessionDelegate {
    
    static let shared = HeartRateMonitor()
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    
    var isMonitoring = false
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            do {
                try session.activate()
            } catch {
                print("Failed to activate WCSession: \(error.localizedDescription)")
            }
        }
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
        
        
        //TODO: Change this to HKWorkout Session's method
        healthStore.end(workoutSession) 
        isMonitoring = false
    }
    
    func sendHeartRateDataToPhone(_ heartRate: Double) {
        guard WCSession.default.isReachable else {
            print("No valid WCSession")
            return
        }
        
        let message = ["heartRate": heartRate]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send heart rate data: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        print("WCSession activation completed with state: \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let heartRate = message["heartRate"] as? Double {
            print("Received heart rate: \(heartRate) bpm")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .notStarted:
            print("Workout session has not started yet.")
        case .running:
            print("Workout session is now running.")
        case .ended:
            print("Workout session has ended.")
        default:
            print("Workout session is in an unknown state.")
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed with error: \(error.localizedDescription)")
        stopMonitoring()
    }
}
