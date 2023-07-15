//
//  AppDelegate.swift
//  Welli-iOS
//
//  Created by Brian Duong on 7/11/23.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            do {
                try session.activate()
            } catch {
                print("Failed to activate WCSession: \(error.localizedDescription)")
            }
        }
        
        return true
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        print("WCSession activation completed with state: \(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession did become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Reactivate session
        print("WCSession did deactivate, reactivating...")
        do {
            try session.activate()
        } catch {
            print("Failed to reactivate WCSession: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let heartRate = message["heartRate"] as? Double {
            // Do something with the received heart rate data
            print("Received heart rate: \(heartRate) bpm")
        }
    }
}
