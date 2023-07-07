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
import HealthKit
import HealthKitUI
import BackgroundTasks
import Firebase
import FirebaseDatabase

struct ContentView: View {
    
    var model = ViewModelPhone()
    @State var reachable = "No"
    @State private var isHealthKitAuthorized = false
    @State private var isNotificationAuthorized = false
    let username = ""  //MARK: CHANGE USERNAME         <-----
    
    
    var body: some View {
        VStack {
            Image(systemName: "wifi")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Welli-iOS Companion App")
            Text("Firebase Connection")
            /*.onAppear {
             requestHealthKitAuthorization()
             scheduleBackgroundTask()
             startHeartRateTracking()
             requestNotificationAuthorization()
             }*/
            //MARK: REACH FIREBASE CONNECT
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
            //MARK: END OF FIREBASE CONNECT
            
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
            
            /*Button("Upload data to Firebase") {
             uploadDataToFirebase()
             }*/
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
