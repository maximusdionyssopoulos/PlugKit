//
//  CBPeripheralState+String.swift
//  PlugKit
//
//  Created by Maximus Dionyssopoulos on 13/2/2025.
//

import CoreBluetooth

extension CBPeripheralState {
    var string: String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        case .disconnecting:
            return "Disconnecting"
        @unknown default:
            return "Unknown"
        }
    }
}
