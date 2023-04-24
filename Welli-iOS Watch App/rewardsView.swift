//
//  rewardsView.swift
//  welli Watch App
//
//

import SwiftUI

//Reward View Interface with Navigation to the Main Page
struct rewardView : View{
   
    @EnvironmentObject var environmentObject: WriteViewModel
    @State var messageText = ""
    
    var body: some View {
        
        ScrollView {
            VStack{
                Image(systemName: "star.fill")
                    .padding()
                Text("Congratualtions. you have received 1 more star. You now have a total of \(self.environmentObject.messageText) stars!")
                NavigationLink(destination: ContentView() ,label:{Text("Repeat")
                        .bold()
                        .frame(width: 120.0, height: 7.0)
                }) .offset(y: 30)
            }.navigationBarBackButtonHidden(true)
        }
    }
}

struct rewardView_Previews: PreviewProvider {
    static let environmentObject = WriteViewModel()
    
    static var previews: some View {
        rewardView().environmentObject(environmentObject)
    }
}
