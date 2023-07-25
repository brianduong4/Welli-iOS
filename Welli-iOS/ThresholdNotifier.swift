//
//  ThredholdNotifier.swift
//  Welli-iOS
//
//  Created by Basel Farag on 7/25/23.
//

import Foundation
import UIKit

class ThresholdNotifier {
    
    static let shared = ThresholdNotifier(username: "Dave")

    var username: String
    
    private var thresholds: [Int: Double] = [
        9: 115, // Ben's 9 - 12
        12: 115, // Ben's 12 - 15
        15: 115, // Ben's 15 - 18
        18: 115 // Ben's 18 - 22
    ]
    
    private var heartRateSamples: [Double] = [] // Here it's an array of doubles for simplicity. You may need to adjust this according to your specific case.
    
    private init(username: String) {
        self.username = username
    }
    
    func handleHeartRateSample(_ heartRateSample: Double) {
        heartRateSamples.append(heartRateSample)
        if heartRateSamples.count >= 3 {
            if let threshold = getThreshold() {
                if heartRateSamples.filter({ $0 > threshold }).count >= 3 {
                    NotificationManager.shared.scheduleNotification(with: "Hi \(username), how do you feel?", body: "How do you feel? Open the app to check in.", interval: 1)
                }
            }
            heartRateSamples.removeFirst() // Remove the oldest sample to keep the last three samples.
        }
    }
    
    private func getThreshold() -> Double? {
        let currentHour = Calendar.current.component(.hour, from: Date())
        if currentHour >= 9 && currentHour < 12 {
            return thresholds[9]
        } else if currentHour >= 12 && currentHour < 15 {
            return thresholds[12]
        } else if currentHour >= 15 && currentHour < 18 {
            return thresholds[15]
        } else if currentHour >= 18 && currentHour < 22 {
            return thresholds[18]
        }
        return nil
    }
}
