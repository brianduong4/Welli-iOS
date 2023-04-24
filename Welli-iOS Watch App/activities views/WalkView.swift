//
//  WalkView.swift
//  welli Watch App
//
//  Created by Brian Duong on 2/27/23.
//

import SwiftUI
import UIKit
import HealthKit

struct WalkView: View {
    
    @State var num = 0.0
    @State var scale = 1.0

    
    
    var body: some View{
        ScrollView{
            VStack{
                Text("Take a Walk. Click finish when you are done.")
                    .padding()
                    .frame(width:200, height: 100)
                Image(uiImage: UIImage(named:"walk.png")!)
                    .frame(width: 95, height: 15)
                    .scaleEffect(scale)
                    .onAppear {
                        let baseAnimation = Animation.easeInOut(duration: 5)
                        let repeated = baseAnimation.repeatForever(autoreverses: true)
                        
                        withAnimation(repeated) {
                            scale = 0.5
                        }
                    }
                NavigationLink(destination: finishView(), label:{ Text("Finished")
                        .bold()
                }).offset(y:15)
                //start of animation
                    .opacity(num)
                    .onAppear
                {
                    let delay = Animation.easeIn(duration: 1).delay(5)
                    
                    withAnimation(delay)
                    {
                        num += 1
                    }
                }
            }.navigationBarBackButtonHidden(true)
        }
    }
}

struct WalkView_Previews: PreviewProvider {
    static var previews: some View {
        WalkView()
    }
}
