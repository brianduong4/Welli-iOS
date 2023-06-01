//
//  WriteViewModel.swift
//  welli Watch App
//
//  Created by Brian Duong on 3/8/23.
//

import Foundation
import UIKit
import SwiftUI
import WatchConnectivity
import WatchKit
import UserNotifications



class WriteViewModel: NSObject, WCSessionDelegate, ObservableObject{
    
    //INITIATED ACTIVITY DATA VARIABLE
    @Published var data: [String: String] = [:]
    
    //INITIATED NOTIFICATION DATA VARIABLE
    @Published var notificationData: [String: String] = [:]
    
    var session: WCSession
    
    //FOR REWARDS
    @Published var messageText = ""
    
    init(session: WCSession = .default){
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    //MARK: RECIEVE REWARD
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.messageText = message["message"] as? String ?? "Unknown"
            
            print(self.messageText)
        }
    }
        
    
    
    //MARK: SEND ACTIVITY DATA
    func sendDictionaryToiOSApp(_ dictionary: [String: Any]) {
        let session = WCSession.default
        if session.isReachable {
            print("ios connection reachable")
            print("Sending dictionary: \(dictionary)")
            session.sendMessage(dictionary, replyHandler: nil, errorHandler: nil)
        }
    }
    
    //MARK: SEND NOTIFICATION DATA
    func sendNotificationDataToiOSApp(_ dictionary: [String: Any]) {
        let session = WCSession.default
        if session.isReachable {
            print("ios connection reachable")
            print("Sending dictionary: \(dictionary)")
            session.sendMessage(dictionary, replyHandler: nil, errorHandler: nil)
        }
    }
}

class InterfaceController: WKInterfaceController {
    
    var sessionDelegate = WriteViewModel()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Set the delegate for the WCSession instance
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = sessionDelegate
            session.activate()
        }
    }
    
    // Other methods of the InterfaceController class go here
    
}

//MARK: current date & time
class MyStruct: ObservableObject{
    @Published var currentDate: String
    @Published var currentMilitary: String
    
    init() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"
        currentMilitary = formatter.string(from: now)
        formatter.dateStyle = .short
        //formatter.timeStyle = .short
        
        currentDate = formatter.string(from: now)
    }
}

var myInstance = MyStruct()
//MARK: END of date & time

//MARK: START of notification center
/*
class SceneDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {
    
    func applicationDidFinishLaunching() {
        requestNotificationAuthorization()
    }
    
    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notifications authorization granted")
            } else {
                print("Notifications authorization denied")
            }
        }
    }
    
    func scheduleNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "My Notification"
        content.body = "This is a notification from my app."
        content.sound = UNNotificationSound.default
        let trigger1 = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: 12), repeats: true)
        let trigger2 = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: 15), repeats: true)
        let trigger3 = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: 18), repeats: true)
        let request1 = UNNotificationRequest(identifier: "notification1", content: content, trigger: trigger1)
        let request2 = UNNotificationRequest(identifier: "notification2", content: content, trigger: trigger2)
        let request3 = UNNotificationRequest(identifier: "notification3", content: content, trigger: trigger3)
        let center = UNUserNotificationCenter.current()
        center.add(request1)
        center.add(request2)
        center.add(request3)
    }
    	
}*/



