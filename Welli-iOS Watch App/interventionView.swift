//
//  ContentView.swift
//  welli Watch App
//
//  Created by Keilen Perez on 12/18/22.
//

import SwiftUI
import UIKit

//This view give the list of intervention activites that the user can pick, this interface is connect with an array and class found at the bottom of this file
struct interventionView : View{
    @EnvironmentObject var environmentObject: WriteViewModel
    @State var num = 0.0
    @State var scale = 1.0
    var body: some View{
        var buttonTapped = true

        NavigationView()
        {
            ScrollView {
                LazyVStack{
                    ZStack{Image(systemName:"circle").frame(width: 25.0, height: 10.0)
                            .offset(x: -65)
                            .multilineTextAlignment(.leading)
                        NavigationLink(destination: deepBreathingView(), label:{ Text("Deep Breath")
                        })}
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["intervention"] = "Breathing"
                                
                                //print(environmentObject.data)

                            }
                        })
                .onChange(of: environmentObject.data) {
                    newEnvironmentObject in print("State: \(newEnvironmentObject)")
                }
                
                LazyVStack{
                    ZStack{Image(systemName:"circle").frame(width: 25.0, height: 10.0)
                            .offset(x: -65)
                            .multilineTextAlignment(.leading)
                        NavigationLink(destination: drinkView(), label:{ Text("Drink Water")
                        })}
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["intervention"] = "Drinking water"
                                
                                //print(environmentObject.data)
                            }
                        })
                LazyVStack {
                    ZStack{Image(systemName:"circle").frame(width: 25.0, height: 10.0)
                            .offset(x: -65)
                            .multilineTextAlignment(.leading)
                        NavigationLink(destination: WalkView(), label:{ Text("Go Take a Walk")
                        })}
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["intervention"] = "Walk"
                                
                                //print(environmentObject.data)
                            }
                        })
                /*LazyVStack {
                    ZStack{Image(systemName:"circle").frame(width: 25.0, height: 10.0)
                            .offset(x: -65)
                            .multilineTextAlignment(.leading)
                        NavigationLink(destination: WalkView(), label:{ Text("Exercise")
                        })}
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["intervention"] = "Exercise"
                                
                                //print(environmentObject.data)
                            }
                        })*/
                
                LazyVStack {
                    ZStack{Image(systemName:"circle").frame(width: 25.0, height: 10.0)
                            .offset(x: -65)
                            .multilineTextAlignment(.leading)
                        NavigationLink(destination: JournalView(), label:{ Text("Journaling")
                        })}
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["intervention"] = "Journaling"
                                
                                //print(environmentObject.data)

                            }
                        })
                    
                LazyVStack {
                    ZStack{Image(systemName:"circle").frame(width: 25.0, height: 10.0)
                            .offset(x: -65)
                            .multilineTextAlignment(.leading)
                        NavigationLink(destination: gameView(), label:{ Text("Play a Game")
                        })}
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["intervention"] = "Game"
                                
                                //print(environmentObject.data)

                            }
                        })
                /*LazyVStack {
                    ZStack{Image(systemName:"circle").frame(width: 25.0, height: 10.0)
                            .offset(x: -65)
                            .multilineTextAlignment(.leading)
                        NavigationLink(destination: gameView(), label:{ Text("Do a Puzzle")
                        })}
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["intervention"] = "Puzzle"
                                
                                //print(environmentObject.data)

                            }
                        })*/
                /*LazyVStack {
                    ZStack{Image(systemName:"circle").frame(width: 25.0, height: 10.0)
                            .offset(x: -65)
                            .multilineTextAlignment(.leading)
                        NavigationLink(destination: ReadView(), label:{ Text("Watch TV")
                        })}
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["intervention"] = "Watch TV"
                                
                                //print(environmentObject.data)

                            }
                        })*/
                
                LazyVStack {
                    ZStack{Image(systemName:"circle").frame(width: 25.0, height: 10.0)
                            .offset(x: -65)
                            .multilineTextAlignment(.leading)
                        NavigationLink(destination: MusicView(), label:{ Text("Listen to Music")
                        })}
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["intervention"] = "Listening to Music"
                                
                                //print(environmentObject.data)

                            }
                        })
                
                /*LazyVStack {
                    ZStack{Image(systemName:"circle").frame(width: 25.0, height: 10.0)
                            .offset(x: -65)
                            .multilineTextAlignment(.leading)
                        NavigationLink(destination: TalkView(), label:{ Text("Talk to Someone")
                        })}
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["intervention"] = "Conversation"
                                
                               // print(environmentObject.data)

                            }
                        })*/
                
                LazyVStack {
                    ZStack{Image(systemName:"circle").frame(width: 25.0, height: 10.0)
                            .offset(x: -65)
                            .multilineTextAlignment(.leading)
                        NavigationLink(destination: happyPictureView(), label:{ Text("Happy Picture")
                        })}
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded{
                            buttonTapped = true
                            if buttonTapped == true {
                                environmentObject.data["intervention"] = "Happy pictures"
                                
                                //print(environmentObject.data)

                            }
                        })
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let environmentObject = WriteViewModel()
    
    static var previews: some View {
        interventionView().environmentObject(environmentObject)
    }
}

