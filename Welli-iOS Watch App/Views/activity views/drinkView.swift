//
//  drinkView.swift
//  welli Watch App
//
//  Created by Brian Duong on 2/21/23.
//

import SwiftUI
import UIKit
import HealthKit

struct drinkView : View{
    
    @State var num = 0.0
    @State var scale = 1.0
    
    @State private var currentImage = 0
    let images = (0...249).compactMap { UIImage(named: "frame_\($0)_delay-0.03s") }

    var body: some View{
        ScrollView{
            VStack{
                Text("Drink some water. Click finish when you are done.")
                    .padding()
                    .frame(width:200, height: 100)
                
                Image(uiImage: images[currentImage])
                            .resizable()
                            .scaledToFit()
                            .offset(y:-30)
                            .frame(width: 130, height: 100)
                            .onAppear {
                                Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { timer in
                                    withAnimation(Animation.linear(duration: 0.0)) {
                                        currentImage = (currentImage + 1) % images.count
                                    }
                                }
                            }
                
                
                NavigationLink(destination: finishView(), label:{ Text("Finished")
                        .bold()
                }).offset(y:-30)
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

struct drinkView_Previews: PreviewProvider {
    static var previews: some View {
        drinkView()
    }
}
