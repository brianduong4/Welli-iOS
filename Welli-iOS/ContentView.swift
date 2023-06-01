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

struct ContentView: View {
    
    var model = ViewModelPhone()
    @State var reachable = "No"
    

    var body: some View {
        VStack {
            Image(systemName: "wifi")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Welli-iOS Companion App")
            Text("Firebase Connection")
            
            //MARK: Start Method #3
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
            
            Button("Schedule 12pm Notification", action: TwelvePMNotification)
            Button("Schedule 3pm Notification", action: ThreePMNotification)
            Button("Schedule 6pm Notification", action: SixPMNotification)
        }
        .padding()
    }
    
    func TwelvePMNotification() {
            let identifier = "12pm-notfication"
            let title = "Time to work out"
            let body = "Don't be a lazy little butt!"
            let hour = 12
            let minute = 00
            let isDaily = true
            
            let notificationCenter = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            let calendar = Calendar.current
            var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
            notificationCenter.add(request)
        }
    
    func ThreePMNotification() {
            let identifier = "3pm-notfication"
            let title = "Time to work out"
            let body = "Don't be a lazy little butt!"
            let hour = 15
            let minute = 00
            let isDaily = true
            
            let notificationCenter = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            let calendar = Calendar.current
            var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
            notificationCenter.add(request)
        }
    
    func SixPMNotification() {
            let identifier = "6pm-notfication"
            let title = "Time to work out"
            let body = "Don't be a lazy little butt!"
            let hour = 18
            let minute = 00
            let isDaily = true
            
            let notificationCenter = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            let calendar = Calendar.current
            var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
            notificationCenter.add(request)
        }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
