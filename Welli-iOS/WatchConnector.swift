//
//  WatchConnector.swift
//  Welli-iOS
//
//  Created by Brian Duong on 4/4/23.
//

import Foundation
import WatchConnectivity
import UIKit
import Swift
import SwiftUI
import FirebaseDatabase

class ViewModelPhone : NSObject,  WCSessionDelegate{
    @Published var messageText = ""

    private let ref = Database.database().reference()
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    var session: WCSession
    
    init(session: WCSession = .default){
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    func sendDictionaryToiOSApp(_ dictionary: [String: Any]) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(dictionary, replyHandler: nil, errorHandler: nil)
        }
    }
    
    // Handle the received message here
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received dictionary: \(message)")
        
        //MARK: Push dictionary data to firebase database under "iOS"
        self.ref.child("ios").childByAutoId().setValue(message)

        //MARK: Push Rewards
        let username:String = message["user"] as! String //GET username from dictionary NOT IN FIREBASE
        
        //If rewards finds username
        ref.child("Rewards").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild("\(username)"){
                
                let starHandler = self.ref.child("Rewards").child("\(username)").child("reward") //Goes to the rewards of that user in firebase
                
                starHandler.observeSingleEvent(of: .value) { (snapshot) in
                    //If the value of the user stars is an Integer, add 1
                    if let value = snapshot.value as? Int {
                        starHandler.setValue(value + 1)
                        
                        //Send Reward data back to watch app
                        if session.isReachable {
                            let total = value + 1
                            print("sending reward \(total)")
                            session.sendMessage(["message": "\(total)"], replyHandler: nil) { (error) in
                                print(error.localizedDescription)
                            }
                        }
                        
                    } else { //else give user 1 star
                        starHandler.setValue(1)
                    }
                    
                }
                
            } else { //ELSE if user is not found, create under REWARDS node username and give 1 to rewards
                self.ref.child("Rewards").child("\(username)").setValue(["reward": 1])
                
                //Send Reward data back to watch app just 1
                if session.isReachable {
                    print("sending new reward 1")
                    session.sendMessage(["message": "1"], replyHandler: nil) { (error) in
                        print(error.localizedDescription)
                    }
                }
            }
        })
        
    }
    
    
}

