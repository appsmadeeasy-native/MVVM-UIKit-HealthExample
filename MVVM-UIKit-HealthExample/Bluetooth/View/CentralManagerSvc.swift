//
//  CentralManagerSvc.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 4/1/21.
//

import Foundation
import CoreBluetooth

class CentralManagerSvc: NSObject {
    
    var mCentralManager: CBCentralManager?
    var mDevice: Device?
    var mServiceUUID: CBUUID?
    var mReadingListClosure: ([Dictionary<String,String>]) -> Void = {_ in}
    var mReadingList = Dictionary<String,Dictionary<String,String>>()
    var discoveredPeripheral: CBPeripheral?
    
    init(device: Device, readingListClosure: @escaping ([Dictionary<String,String>]) -> Void) {
        super.init()
        mDevice = device
        mReadingListClosure = readingListClosure
        mServiceUUID = CBUUID(string: device.serviceUUID)
        mCentralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    deinit {
        mCentralManager?.stopScan()
        print("Scanning stopped")
    }
    
    // MARK: - Public Methods
    
    public func startScan() {
        self.mCentralManager?.scanForPeripherals(withServices: [mServiceUUID!],
                                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    public func stopScan() {
        self.mCentralManager?.stopScan()
    }
    
    
    // MARK: - Helper Methods

    // We will first check if we are already connected to our counterpart
    // Otherwise, scan for peripherals - specifically for our service's 128bit CBUUID
    private func retrievePeripheral() {
        
        let connectedPeripherals: [CBPeripheral] = (mCentralManager!.retrieveConnectedPeripherals(withServices: [mServiceUUID!]))
        
        print("Found connected Peripherals with transfer service: \(connectedPeripherals)")
        
        if let connectedPeripheral = connectedPeripherals.last {
            print("Connecting to peripheral \(connectedPeripheral)")
            self.discoveredPeripheral = connectedPeripheral
            mCentralManager?.connect(connectedPeripheral, options: nil)
        } else {
            // We were not connected to our counterpart, so start scanning
            mCentralManager?.scanForPeripherals(withServices: [mServiceUUID!],
                                               options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    // Call this when things either go wrong, or you're done with the connection.
    // This cancels any subscriptions if there are any, or straight disconnects if not.
    // (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
    private func cleanup() {
        // Don't do anything if we're not connected
        guard let discoveredPeripheral = discoveredPeripheral,
            case .connected = discoveredPeripheral.state else { return }
        
        for service in (discoveredPeripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.isNotifying {
                    // It is notifying, so unsubscribe
                    self.discoveredPeripheral?.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        // If we've gotten this far, we're connected, but we're not subscribed, so we just disconnect
        mCentralManager?.cancelPeripheralConnection(discoveredPeripheral)
    }
    
}


extension CentralManagerSvc: CBCentralManagerDelegate {
    
    // centralManagerDidUpdateState is a required protocol method.
    // Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
    // In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
    // the Central is ready to be used.
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {

        switch central.state {
        case .poweredOn:
            // start working with the peripheral
            print("CBManager is powered on")
            retrievePeripheral()
        case .poweredOff:
            print("CBManager is not powered on")
            // In a real app, you'd deal with all the states accordingly
            return
        case .resetting:
            print("CBManager is resetting")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unauthorized:
            // In a real app, you'd deal with all the states accordingly
            return
        case .unknown:
            print("CBManager state is unknown")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unsupported:
            print("Bluetooth is not supported on this device")
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            print("A previously unknown central manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }

    // This callback comes whenever a peripheral that is advertising the transfer serviceUUID is discovered.
    // We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
    // we start the connection process
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        // Reject if the signal strength is too low to attempt data transfer.
        // Change the minimum RSSI value depending on your app’s use case.
        guard RSSI.intValue >= -50
            else {
            print("Discovered perhiperal not in expected range, at \(RSSI.intValue)")
                return
        }
        
        print("Discovered \(String(describing: peripheral.name)) at \(RSSI.intValue)")

        // Device is in range - have we already seen it?
        if discoveredPeripheral != peripheral {
            
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it.
            discoveredPeripheral = peripheral
            
            // And finally, connect to the peripheral.
            print("Connecting to perhiperal \(peripheral)")
            mCentralManager?.connect(peripheral, options: nil)
        }
    }

    // If the connection fails for whatever reason, we need to deal with it.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to %@. %s", peripheral, String(describing: error))
        cleanup()
    }
 
    // We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected")
        
        // Stop scanning
        mCentralManager?.stopScan()
        print("Scanning stopped")
        
        // Make sure we get the discovery callbacks
        peripheral.delegate = self
        
        // Search only for services that match our UUID
        peripheral.discoverServices([mServiceUUID!])
    }
    
    // Once the disconnection happens, we need to clean up our local copy of the peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Perhiperal Disconnected")
        discoveredPeripheral = nil
        
        if (mReadingList.count > 0) {
            mReadingListClosure(mReadingList.map { return $0.value })
        }
    }
}

extension CentralManagerSvc: CBPeripheralDelegate {
    
    // implementations of the CBPeripheralDelegate methods

    // The peripheral letting us know when services have been invalidated.
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
        for service in invalidatedServices where service.uuid == mServiceUUID! {
            print("Transfer service is invalidated - rediscover services")
            peripheral.discoverServices([mServiceUUID!])
        }
    }

    // The Transfer Service was discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            print(service.characteristics as Any)
            if let device = mDevice {
                if (device.characteristicUUID.count > 0) {
                    peripheral.discoverCharacteristics([CBUUID(string: device.characteristicUUID)], for: service)
                }
                if (device.characteristicUUID2.count > 0) {
                    peripheral.discoverCharacteristics([CBUUID(string: device.characteristicUUID2)], for: service)
                }
                if (device.characteristicUUID3.count > 0) {
                    peripheral.discoverCharacteristics([CBUUID(string: device.characteristicUUID3)], for: service)
                }
            }
        }
    }

    // The Transfer characteristic was discovered.
    // Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        // Again, we loop through the array, just in case and check if it's the right one
        guard let serviceCharacteristics = service.characteristics else { return }
        for characteristic in serviceCharacteristics {
            // If it is, subscribe to it
            print(characteristic.uuid)
            peripheral.setNotifyValue(true, for: characteristic)
        }
        
        // Once this is complete, we just need to wait for the data to come in.
    }
    
    // his callback lets us know more data has arrived via notification on the characteristic
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        if let data = characteristic.value {
            var bytes = Array(repeating: 0 as UInt8, count:data.count/MemoryLayout<UInt8>.size)

            data.copyBytes(to: &bytes, count:data.count)
            let data16 = bytes.map { UInt8($0) }
            guard let device = mDevice else {
                return
            }
            switch device.deviceType {
            case "Glumeter":
                let parser = BluetoothBytesParser(value: data16)
                let flags = parser.getIntValue(formatType: BluetoothBytesParser.FORMAT_UINT8)
                let typeAndLocationPresent = (flags & 0x02) > 0
                
                var glucoseValue: Float?
                if (typeAndLocationPresent) {
                    let glucoseConcentration = parser.getFloatValue(formatType: BluetoothBytesParser.FORMAT_SFLOAT)
                    glucoseValue = glucoseConcentration * 100000;
                }

                let timestamp = parser.getDateTime()
                print(timestamp)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
                let date = dateFormatter.string(from: timestamp)
        
                let bgDict = ["glucose":String(format: "%.0f", glucoseValue!), "createdTime":date]
                mReadingList[date] = bgDict

                // Forcing a disconnect peripheral here
                self.mCentralManager?.cancelPeripheralConnection(discoveredPeripheral!)
                discoveredPeripheral = nil
                mReadingListClosure(mReadingList.map { return $0.value })
                
            case "Blood Pressure":
                let parser = BluetoothBytesParser(value: data16)
                let flags = parser.getIntValue(formatType: BluetoothBytesParser.FORMAT_UINT8)
                let timestampPresent = (flags & 0x02) > 0
                
                let systolicValue = parser.getFloatValue(formatType: BluetoothBytesParser.FORMAT_SFLOAT)
                let diastolicValue = parser.getFloatValue(formatType: BluetoothBytesParser.FORMAT_SFLOAT)
                parser.setOffset(offset: 14)
                let bmpValue = parser.getFloatValue(formatType: BluetoothBytesParser.FORMAT_SFLOAT)
                
                parser.setOffset(offset: 7)
                var timestamp: Date?
                if (timestampPresent) {
                    timestamp = parser.getDateTime()
                    print(timestamp!)
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
                let date = dateFormatter.string(from: timestamp!)
                
                let bgDict = ["systolic":String(format: "%.0f", systolicValue), "diastolic":String(format: "%.0f", diastolicValue), "bmp":String(format: "%.0f", bmpValue), "createdTime":date]
                mReadingList[date] = bgDict
 
                mReadingListClosure(mReadingList.map { return $0.value })
                
            case "Weight Scale":
                let parser = BluetoothBytesParser(value: data16)
                let flags = parser.getIntValue(formatType: BluetoothBytesParser.FORMAT_UINT8)
                let unit = ((flags & 0x01) > 0) ? WeightUnit.Pounds : WeightUnit.Kilograms
                let timestampPresent = (flags & 0x02) > 0
                
                let weightMultiplier = (unit == WeightUnit.Kilograms) ? 0.005 : 0.01
                let weight = Double(parser.getIntValue(formatType: BluetoothBytesParser.FORMAT_UINT16))
                    * weightMultiplier
                print(weight)
                
                var timestamp: Date?
                if (timestampPresent) {
                    timestamp = parser.getDateTime()
                    print(timestamp!)
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
                let date = dateFormatter.string(from: timestamp!)
                
                
                let bgDict = ["weight":String(format: "%.01f", weight), "createdTime":date]
                mReadingList[date] = bgDict
                
                mReadingListClosure(mReadingList.map { return $0.value })
                
            case "Thermometer":
                let parser = BluetoothBytesParser(value: data16)
                let flags = parser.getIntValue(formatType: BluetoothBytesParser.FORMAT_UINT8)
                let timestampPresent = (flags & 0x02) > 0
                
                let temperatureValue = (parser.getFloatValue(formatType: BluetoothBytesParser.FORMAT_FLOAT) * 1.8) + 32.0
                
                var timestamp: Date?
                if (timestampPresent) {
                    timestamp = parser.getDateTime()
                    print(timestamp!)
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
                let date = dateFormatter.string(from: timestamp!)
                
                let bgDict = ["temperature":String(format: "%.01f", temperatureValue), "createdTime":date]
                mReadingList[date] = bgDict
                
                // Forcing a disconnect peripheral here
                self.mCentralManager?.cancelPeripheralConnection(discoveredPeripheral!)
                discoveredPeripheral = nil
                mReadingListClosure(mReadingList.map { return $0.value })

            case "Pulse Oximeter":
                let parser = BluetoothBytesParser(value: data16)
                let flags = parser.getIntValue(formatType: BluetoothBytesParser.FORMAT_UINT8)

                let timestampPresent = (flags & 0x02) > 0
                
                let spO2Value = parser.getFloatValue(formatType: BluetoothBytesParser.FORMAT_SFLOAT)
                let bmpValue = parser.getFloatValue(formatType: BluetoothBytesParser.FORMAT_SFLOAT)

                var timestamp: Date?
                if (timestampPresent) {
                    timestamp = parser.getDateTime()
                    print(timestamp!)
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
                let date = dateFormatter.string(from: timestamp!)
                
                let bgDict = ["spo2":String(format: "%.0f", spO2Value), "bmp":String(format: "%.0f", bmpValue), "createdTime":date]
                mReadingList[date] = bgDict
  
                mReadingListClosure(mReadingList.map { return $0.value })
                
            default:
                print("default: No readings")
            }
        }
    }

    // The peripheral letting us know whether our subscribe/unsubscribe happened or not
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error changing notification state: \(error.localizedDescription)")
            return
        }
        
        if characteristic.isNotifying {
            print("Notification began on \(characteristic)")
        } else {
            print("Notification stopped on \(characteristic). Disconnecting")
            cleanup()
        }
        
    }
   
}
