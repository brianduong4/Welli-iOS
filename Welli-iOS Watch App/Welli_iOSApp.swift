//
//  Welli_iOSApp.swift
//  Welli-iOS Watch App
//
//  Created by Brian Duong on 4/4/23.
//

import SwiftUI


@main
struct Welli_iOS_Watch_AppApp: App {
    @StateObject var environmentObject = WriteViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(environmentObject)
        }
    }
}
