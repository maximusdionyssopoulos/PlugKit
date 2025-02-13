//
//  PlugKitApp.swift
//  PlugKit
//
//  Created by Maximus Dionyssopoulos on 13/2/2025.
//

import SwiftUI

@main
struct PlugKitApp: App {
    
    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            Label("Smart Plug", systemImage: "powerplug.portrait.fill")
        }
    }
}
