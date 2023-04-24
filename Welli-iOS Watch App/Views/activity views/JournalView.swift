//
//  JournalView.swift
//  welli Watch App
//
//  Created by Brian Duong on 2/27/23.
//

import SwiftUI
import UIKit
import HealthKit

struct JournalView: View {
    
    @State var num = 0.0
    @State var scale = 1.0
    
    @State private var currentImage = 0
    let images = (0...10).compactMap { UIImage(named: "frame_0\($0)_delay-0.01s") }
    
    var body: some View{
        ScrollView{
            VStack{
                Text("Take your time to journal. Click finish when you are done.")
                    .padding()
                    .frame(width:200, height: 100)
                
                Image(uiImage: images[currentImage])
                            .resizable()
                            .scaledToFit()
                            .offset(y:-20)
                            .frame(width: 130, height: 100)
                            .onAppear {
                                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                                    withAnimation(Animation.linear(duration: 0.0)) {
                                        currentImage = (currentImage + 1) % images.count
                                    }
                                }
                            }
                
                NavigationLink(destination: finishView(), label:{ Text("Finished")
                        .bold()
                }).offset(y:-10)
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
        }
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
    }
}
