//
//  finishView.swift
//  welli
//
//

import SwiftUI


//This view asks the user whether they have finished either the intervention or breathing and takes them to the next view
struct finishView : View{
    
    @EnvironmentObject var environmentObject: WriteViewModel
    
    
    var body: some View{
        var buttonTapped = false
        
        ScrollView {
            LazyVStack {
                Text("Did You Finish Your Intervention?")
                    .padding()
            }
            
            //YES button -> pass to betterView page
            LazyVStack {
                NavigationLink(destination: betterView(), label:{ Text("Yes")
                        .foregroundColor(.green)
                        .bold()
                })
            }.simultaneousGesture(
                TapGesture()
                    .onEnded{
                        buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["finish_status"] = "Yes"

                            }
                        })
            /*.onChange(of: environmentObject.data) {
                newEnvironmentObject in print("State: \(newEnvironmentObject)")
            }*/
            
            //NO button -> pass to multiple intervention viewpage
            LazyVStack {
                NavigationLink(destination: ContentView(), label:{ Text("No")
                        .foregroundColor(.red)
                        .bold()
                })
            }.simultaneousGesture(
                TapGesture()
                    .onEnded{
                        buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["finish_status"] = "No"
                                print(environmentObject.data)
                                
                            }
                        })
            
        }.navigationBarBackButtonHidden(true)
    }
}

struct finishView_Previews: PreviewProvider {
    static let environmentObject = WriteViewModel()
    
    static var previews: some View {
        finishView().environmentObject(environmentObject)
    }
}
