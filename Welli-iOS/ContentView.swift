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
            
    
        }
        .onAppear{
            //REQUEST NOTIFICATION
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            // create the notification content
            let content = UNMutableNotificationContent()
            content.title = "Welli Check In"
            content.subtitle = "Daily Reminder"
            content.body = "How do you feel? Click the notification to let us know"

            // create a date component for 12pm every day
            var dateComponents = DateComponents()
            dateComponents.hour = 12
            dateComponents.minute = 0

            // create the notification trigger for the 12pm time, repeating every day
            let trigger12pm = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            // set the notification sound to the default critical sound with full volume, which will also vibrate the device 2 times
            content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)
            content.userInfo = ["vibration-pattern": [0.2, 0.2, 0.2, 0.5, 0.2, 0.2, 0.2]]

            // choose a random identifier for the 12pm notification
            let request12pm = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger12pm)

            // add the 12pm notification request
            UNUserNotificationCenter.current().add(request12pm) { error in
                if let error = error {
                    print("Error adding notification: \(error)")
                } else {
                    print("12pm notification added!")
                }
            }

            // create a date component for 3pm every day
            dateComponents.hour = 15
            dateComponents.minute = 0

            // create the notification trigger for the 3pm time, repeating every day
            let trigger3pm = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            // set the notification sound to the default critical sound with full volume, which will also vibrate the device 2 times
            content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)
            content.userInfo = ["vibration-pattern": [0.2, 0.2, 0.2, 0.5, 0.2, 0.2, 0.2]]

            // choose a random identifier for the 3pm notification
            let request3pm = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger3pm)

            // add the 3pm notification request
            UNUserNotificationCenter.current().add(request3pm) { error in
                if let error = error {
                    print("Error adding notification: \(error)")
                } else {
                    print("3pm notification added!")
                }
            }

            // create a date component for 6pm every day
            dateComponents.hour = 18
            dateComponents.minute = 0

            // create the notification trigger for the 6pm time, repeating every day
            let trigger6pm = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            // set the notification sound to the default critical sound with full volume, which will also vibrate the device 2 times
            content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)
            content.userInfo = ["vibration-pattern": [0.2, 0.2, 0.2, 0.5, 0.2, 0.2, 0.2]]

            // choose a random identifier for the 6pm notification
            let request6pm = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger6pm)

            // add the 6pm notification request
            UNUserNotificationCenter.current().add(request6pm) { error in
                if let error = error {
                    print("Error adding notification: \(error)")
                } else {
                    print("6pm notification added!")
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
