//
//  ContentView.swift
//  PlugKit
//
//  Created by Maximus Dionyssopoulos on 13/2/2025.
//

import SwiftUI

struct ContentView: View {
    @State var plugOn = false
    var body: some View {
        VStack {
            Toggle(isOn: $plugOn) {
                Text("Hue Plug")
            }
            .keyboardShortcut("H", modifiers: [.option, .control])
            Divider()
            Button("Quit") {
                
            }
            .keyboardShortcut("Q")
        }
    }
}

#Preview {
    ContentView()
}
