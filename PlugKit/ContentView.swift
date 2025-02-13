//
//  ContentView.swift
//  PlugKit
//
//  Created by Maximus Dionyssopoulos on 13/2/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var bluetoothManager = CorePlug()
    var isConnected: Bool {
        bluetoothManager.smartPlug?.state == .connected && bluetoothManager.smartPlug != nil
    }
    
    var body: some View {
        VStack {
            if !isConnected {
                Text("Connecting...")
            } else {
                Text("Plug name: \(bluetoothManager.smartPlug!.name ?? "")")
                Text("State: \(bluetoothManager.smartPlug!.state.string)")
            }
            
            Toggle(isOn: $bluetoothManager.isSmartPlugOn) {
                Text("Hue Plug")
            }
            .disabled(!isConnected)
            .keyboardShortcut("H", modifiers: [.option, .control])
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("Q")
        }
    }
}

#Preview {
    ContentView()
}
