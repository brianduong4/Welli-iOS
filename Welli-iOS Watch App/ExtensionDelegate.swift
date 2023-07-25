//
//  ExtensionDelegate.swift
//  Welli-iOS Watch App
//
//  Created by Brian Duong on 7/10/23.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    func applicationDidFinishLaunching() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            do {
                try session.activate()
            } catch {
                print("Failed to activate WCSession: \(error.localizedDescription)")
            }
        }
        
        HeartRateMonitor.shared.startMonitoring()
    }
    
    // The workout session will now continue when the app goes into the background
    func applicationWillResignActive() {
        // Do not stop monitoring when app goes to background
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        print("WCSession (watch) activation completed with state: \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let heartRate = message["heartRate"] as? Double {
            print("Received heart rate: \(heartRate) bpm")
            HeartRateMonitor.shared.sendHeartRateDataToPhone(heartRate)
        }
    }
}
