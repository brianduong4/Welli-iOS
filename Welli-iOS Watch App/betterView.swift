//
//  betterView.swift
//  welli Watch App
//
//

import SwiftUI
import HealthKit
import WatchConnectivity

// This view asks whether you feel better and based on your answer takes you to the rewards or back to the main page

struct betterView : View{
    
    @EnvironmentObject var environmentObject: WriteViewModel
    
    
    let healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    let heartrate = HKHeartRateMotionContext.sedentary
    
    @State private var value = 0

    
    @State var reachable = "No"

    @State private var rewards: Int?
    
    
    var body: some View{
        var buttonTapped = false
        
        
        
    ScrollView {
        let heartrate = "\(value)"
        
        LazyVStack {
            Text("Do You Feel Better?")
                .padding()
        }
        LazyVStack {
            
            NavigationLink(destination: rewardView(), label:{ Text("Yes")
                    .foregroundColor(.green)
                    .bold()
            })
        }.simultaneousGesture(
            TapGesture()
                .onEnded{
                    buttonTapped = true
                        if buttonTapped == true {
                            environmentObject.data["type"] = "activity"
                            environmentObject.data["end_mood"] = "Yes"
                            environmentObject.data["hr_after"] = heartrate
                            environmentObject.data["end_time"] = MyStruct.init().currentDate + " " + MyStruct.init().currentMilitary
                            
                            print(environmentObject.sendDictionaryToiOSApp(environmentObject.data))
                        }
                    })
    
        LazyVStack {
            NavigationLink(destination: rewardView(), label:{ Text("No")
                    .foregroundColor(.red)
                    .bold()
            })
        }.simultaneousGesture(
            TapGesture()
                .onEnded{
                    buttonTapped = true
                        if buttonTapped == true {
                            environmentObject.data["type"] = "activity"
                            environmentObject.data["finish_status"] = "Yes"
                            environmentObject.data["hr_after"] = heartrate
                            environmentObject.data["end_time"] = MyStruct.init().currentDate + " " + MyStruct.init().currentMilitary
                            
                            //print(environmentObject.data)
                            print(environmentObject.sendDictionaryToiOSApp(environmentObject.data))
            
                        }
                    })
    }.navigationBarBackButtonHidden(true)
            .onAppear(perform: start)
    }
    
    //MARK: START HEARTRATE QUERY
    func start() {
        authorizeHealthkit()
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
    }

    func authorizeHealthkit() {
        // Used to define the identifiers that create quanitity type objects.
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]

        // Request permission to save and read the specified data types.
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) {
            (success, error)
            in
        }
    }

    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        // We want data points from our current device
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        
        // A query that returns changes to the HealthKit store, including a snapshot of new changes and continuous monitoring as a long-runninig query.
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            
        // A sample that represents a quantity, including the value and the units.
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            
            self.process(samples, type: quantityTypeIdentifier)
            
        }
        
        // It provides us with both the ability to receive a snapshot of data, and then on subsequeny calls, a snapshot of what has changed.
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        query.updateHandler = updateHandler
        
        // query execution
        
        healthStore.execute(query)
    }

    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        // variable initialization
        var lastHeartRate = 0.0
        
        // cycle and value assignment
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
            
            
            self.value = Int(lastHeartRate)
        }
    }
    //MARK: END HEARTRATE QUERY
}

struct betterView_Previews: PreviewProvider {
    static let environmentObject = WriteViewModel()
    
    static var previews: some View {
        betterView().environmentObject(environmentObject)
            
    }
}
