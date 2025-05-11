//
//  ContentView.swift
//  SceneKitTesting
//
//  Created by Andrei Goncharenko on 14.01.2025.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @State var roomNumber: String = ""
    @State var startRoomNumber: String = ""
    var body: some View {
        ZStack(alignment: .top) {
            Text("Maps")
                .font(.largeTitle.weight(.heavy))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(30)
                .zIndex(3)
                .background(.ultraThinMaterial)
            VStack {
                ZStack(alignment: .bottom) {
                    SceneKitView(startNode: startRoomNumber, goalNode: roomNumber)
                        .edgesIgnoringSafeArea(.all) // Optional: to make the SceneKit view full screen
                    // .padding(.bottom, 100)
                        .zIndex(0)
                    HStack (spacing: 0) {
                        TextField("Начало", text: $startRoomNumber)
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .keyboardType(.default)
                            .zIndex(2)
                        .background(.ultraThinMaterial)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Конец", text: $roomNumber)
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .keyboardType(.default)
                            .zIndex(2)
                            .background(.ultraThinMaterial)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
