//
//  Welli_iOSApp.swift
//  Welli-iOS
//
//  Created by Brian Duong on 4/4/23.
//

import SwiftUI
import Firebase

@main
struct Welli_iOSApp: App {
    
    
    
    init() {
        FirebaseApp.configure()
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
