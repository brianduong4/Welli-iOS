//
//  Welli_iOSApp.swift
//  Welli-iOS Watch App
//
//  Created by Brian Duong on 4/4/23.
//
//MARK: THIS IS THE MAIN CONTROL POINT OF THE APP UPON LAUNCH


import SwiftUI
import WatchKit
import UserNotifications
import WatchConnectivity
import HealthKit
import UIKit

/*class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {
    
    func applicationDidFinishLaunching() {
        // Set the delegate for UNUserNotificationCenter
        UNUserNotificationCenter.current().delegate = self
        
        // Request user authorization for notifications
        let options: UNAuthorizationOptions = [.alert, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if let error = error {
                print("Failed to request authorization for notifications: \(error.localizedDescription)")
            }
        }
        
        // Other app initialization code...
    }
    
    // Handle user notification interactions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received notification response: \(response)")
        
        if response.notification.request.identifier == "Threshold-Notification" {
            print("Matching notification identifier found")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        
        completionHandler()
    }

    // Other delegate methods...
    
}*/




@main
/*struct ExtensionDelegate: WKExtensionDelegate {
    func applicationDidFinishLaunching() {
        requestHealthKitAuthorization()
    }

    private func requestHealthKitAuthorization() {
        let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        HKHealthStore().requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization granted")
            } else {
                print("Failed to authorize HealthKit access: \(error?.localizedDescription ?? "")")
            }
        }
    }
}*/


struct Welli_iOS_Watch_AppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    
    @StateObject var environmentObject = WriteViewModel()

    
    init() {
        HeartRateMonitor.shared.startMonitoring()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(environmentObject).onAppear {
                if WCSession.isSupported() {
                    WCSession.default.activate()
                }
            }
            
        }
        
    }
}

