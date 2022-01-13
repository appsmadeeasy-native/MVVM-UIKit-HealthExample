//
//  StorableDevice.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/19/21.
//

import Foundation
import RealmSwift

extension Device: Entity {

    private var storableDevice: StorableDevice {
        let realmDevice = StorableDevice()
        realmDevice.deviceType = deviceType
        realmDevice.serviceUUID = serviceUUID
        realmDevice.characteristicUUID = characteristicUUID
        realmDevice.characteristicUUID2 = characteristicUUID2
        realmDevice.characteristicUUID3 = characteristicUUID3
        realmDevice.characteristicUUID4 = characteristicUUID4
        realmDevice.lastReadingValue1 = lastReadingValue1
        realmDevice.lastReadingValue2 = lastReadingValue2
        realmDevice.lastReadingValue3 = lastReadingValue3
        realmDevice.lastReadingTimestamp = lastReadingTimestamp
        realmDevice.readingScale = readingScale
        realmDevice.uuid = NSUUID().uuidString
        return realmDevice
    }
    
    func toStorable() -> StorableDevice {
        return storableDevice
    }
}

class StorableDevice: Object, Storable {
    
    @objc dynamic var deviceType: String = ""
    @objc dynamic var serviceUUID: String = ""
    @objc dynamic var characteristicUUID: String = ""
    @objc dynamic var characteristicUUID2: String = ""
    @objc dynamic var characteristicUUID3: String = ""
    @objc dynamic var characteristicUUID4: String = ""
    @objc dynamic var lastReadingValue1: String = ""
    @objc dynamic var lastReadingValue2: String = ""
    @objc dynamic var lastReadingValue3: String = ""
    @objc dynamic var lastReadingTimestamp: String = ""
    @objc dynamic var readingScale: String = ""
    @objc dynamic var uuid: String = ""
    
    var model: Device
    {
        get {
            return Device(deviceType: deviceType, serviceUUID: serviceUUID, characteristicUUID: characteristicUUID, characteristicUUID2: characteristicUUID2, characteristicUUID3: characteristicUUID3, characteristicUUID4: characteristicUUID4, lastReadingValue1: lastReadingValue1, lastReadingValue2: lastReadingValue2, lastReadingValue3: lastReadingValue3, lastReadingTimestamp: lastReadingTimestamp, readingScale: readingScale)
        }
    }
}
