//
//  happyPictureView.swift
//  welli Watch App
//
//  Created by Brian Duong on 2/27/23.
//

import SwiftUI
import UIKit
import HealthKit

//var images: [String] = ["erin1.jpg","erin2.jpg", "erin3.jpg", "erin4.jpg"] //ERIN'S IMAGES
//var images: [String] = ["Caitlin_1.png","Caitlin_2.png", "Caitlin_3.png", "Caitlin_4.png", "Caitlin_5.png"] //CAITLIN'S IMAGES
//var images: [String] = ["Lauren_1.jpg","Lauren_2.jpg", "Lauren_3.jpg", "Lauren_4.jpg", "Lauren_5.jpg"] //LAUREN'S IMAGES
//var images: [String] = ["Colin_1.jpg","Colin_2.jpg"] //COLIN'S IMAGES
//var images: [String] = ["Mckenna_1.jpg","Mckenna_2.jpg", "Mckenna_3.jpg", "Mckenna_4.jpg", "Mckenna_5.jpg"] //MCKENNA'S IMAGES
var images: [String] = ["pic1bj.jpg","pic2bj.jpg", "pic3bj.jpg", "pic4bj.jpg", "pic5bj.jpg"] //BEN'S IMAGES

let randomImage = images.randomElement()!


struct happyPictureView: View {
    let healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    
    @State var num = 0.0
    @State var scale = 1.0
    @State private var value = 0
    
    var body: some View{
        ScrollView{
            VStack{
                Text("Enjoy your happy picture Ben! Click finish when you are done.")
                    .padding()
                    .frame(width:180, height: 100)
                
                Image(uiImage: UIImage(named:randomImage)!)
                    .resizable()
                    .frame(width: 150, height: 150)
                NavigationLink(destination: finishView(), label:{ Text("Finished")
                        .bold()
                }).offset(y:15)
                //start of animation
                    .opacity(num)
                    .onAppear
                {
                    let delay = Animation.easeIn(duration: 1).delay(2)
                    
                    withAnimation(delay)
                    {
                        num += 1
                    }
                }
            }.navigationBarBackButtonHidden(true)
            .padding()
            .onAppear(perform: start)
        }
    }
    
    func start() {
        authorizeHealthkit()
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
    }

    func authorizeHealthkit() {
        // Used to define the identifiers that create quanitity type objects.
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        /*let typesToShare: Set = [HKQuantityType.quantityType(forIdentifier: .heartRate )]
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!]*/
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
}



struct happyPictureView_Previews: PreviewProvider {
    static var previews: some View {
        happyPictureView()
    }
}
