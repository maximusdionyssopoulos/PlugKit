//
//  CorePlug.swift
//  PlugKit
//
//  Created by Maximus Dionyssopoulos on 13/2/2025.
//

import CoreBluetooth


class CorePlug: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    @Published var  smartPlug: CBPeripheral?
    @Published var isSmartPlugOn: Bool = false {
        didSet {
            if !isUpdatingFromPeripheral {
                togglePlug()
            }
        }
    }
    
    private var centralManager: CBCentralManager!
    private var targetCharacteristic: CBCharacteristic?
    let serviceUUID = CBUUID(string: "932c32bd-0000-47a2-835a-a8d455b859dd")
    let characteristicUUID = CBUUID(string: "932C32BD-0002-47A2-835A-A8D455B859DD")
    
    private var isUpdatingFromPeripheral = false
    
    enum SmartPlugState {
        case on
        case off
        
        var value: UInt8 {
            switch self {
            case .on:
                return 0x01
            case .off:
                return 0x00
            }
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Central state is unknown")
        case .resetting:
            print("Central state is resetting")
        case .unsupported:
            print("Central state is unsupported")
        case .unauthorized:
            print("Central state is unauthorized")
        case .poweredOff:
            print("Central state is poweredOff")
        case .poweredOn:
            print("Central state is poweredOn")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning started")
        @unknown default:
            print("Central state is in an unknown state")
        }
    }
    
    // Tells the delegate the central manager discovered a peripheral while scanning for devices.
    internal func centralManager(_ central: CBCentralManager,didDiscover peripheral: CBPeripheral,advertisementData: [String: Any],rssi RSSI: NSNumber) {
        // TODO: Should make this a setting
        if peripheral.name == "Hue smart plug" {
            print("Found Hue smart plug")
            smartPlug = peripheral
            
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    // Tells the delegate that the central manager connected to a peripheral.
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print(peripheral)
        print("Connected to \(peripheral.name ?? "Unknown Peripheral")")
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    // MARK: - CBPeripheralDelegate
    
    // Tells the delegate that peripheral service discovery succeeded.
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            print("No services found")
            return
        }
        
        for service in services {
            print("Discovered service: \(service)")
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    // Tells the delegate that the peripheral found characteristics for a service.
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            print("No characteristics found for service: \(service)")
            return
        }
        
        for characteristic in characteristics {
            if characteristic.uuid == characteristicUUID {
                print("Found target characteristic: \(characteristic)")
                targetCharacteristic = characteristic
                
                subscribeToPlugState()
                
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    // Tells the delegate that retrieving the specified characteristic’s value succeeded, or that the characteristic’s value changed.
    internal func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error reading characteristic value: \(error.localizedDescription)")
            return
        }
        
        guard let value = characteristic.value else {
            print("Characteristic value is nil")
            return
        }
        
        guard let data = value.first else {
            print("Value is empty")
            return
        }
        
        // Set the flag to prevent togglePlug() from being called
        isUpdatingFromPeripheral = true
        
        if data == SmartPlugState.on.value {
            print("Smart plug is on")
            isSmartPlugOn = true
        } else if data == SmartPlugState.off.value {
            print("Smart plug is off")
            isSmartPlugOn = false
        } else {
            print("Unknown smart plug state: \(data)")
        }
        
        // Reset the flag after updating the state
        isUpdatingFromPeripheral = false
    }
    
    // This is called when a characteristic's value is written
    internal func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing characteristic value: \(error.localizedDescription)")
            return
        }
        
        print("Successfully wrote value to characteristic: \(characteristic)")
    }
    
    func subscribeToPlugState() {
        guard let characteristic = targetCharacteristic,
              let smartPlug = smartPlug else {
            print("Target characteristic or smart plug is nil")
            return
        }
        
        // Enable notifications for the characteristic
        smartPlug.setNotifyValue(true, for: characteristic)
        print("Subscribed to plug state changes")
    }

    // Add this delegate method to receive notifications
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error changing notification state: \(error.localizedDescription)")
            return
        }
        
        if characteristic.isNotifying {
            print("Successfully subscribed to notifications")
        } else {
            print("Notifications disabled")
        }
    }
    
    // MARK: - Toggling the plug's power state
    
    public func togglePlug() {
        guard let characteristic = targetCharacteristic,
              let smartPlug = smartPlug else {
            print("Target characteristic or smart plug is nil")
            return
        }
        
        // default to turn off
        var command: UInt8 = SmartPlugState.off.value
        if isSmartPlugOn {
            // already off so turn it on
            command = SmartPlugState.on.value
        }
        
        let data = Data([command])
        smartPlug.writeValue(data, for: characteristic, type: .withResponse)
    }
}
