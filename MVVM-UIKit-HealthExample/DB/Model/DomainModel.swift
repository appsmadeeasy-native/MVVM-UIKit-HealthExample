//
//  DomainModel.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 4/30/21.
//

import Foundation

protocol DomainModel {
    associatedtype DomainModelType
    func toDomainModel() -> DomainModelType
}

extension DeviceMO: DomainModel {
    func toDomainModel() -> Device {
        return Device(deviceType: deviceType!,
                      serviceUUID: serviceUUID!,
                      characteristicUUID: characteristicUUID!,
                      characteristicUUID2: characteristicUUID2!,
                      characteristicUUID3: characteristicUUID3!,
                      characteristicUUID4: characteristicUUID4!,
                      lastReadingValue1: lastReadingValue1!,
                      lastReadingValue2: lastReadingValue2!,
                      lastReadingValue3: lastReadingValue3!,
                      lastReadingTimestamp: lastReadingTimestamp!,
                      readingScale: readingScale!)
    }
}

extension VitalReadingMO: DomainModel {
    func toDomainModel() -> VitalReading {
        return VitalReading(createdTimestamp: createdTimestamp!,
                            readingValue1: readingValue1!,
                            readingValue2: readingValue2!,
                            readingValue3: readingValue3!,
                            isBluetooth: isBluetooth,
                            vitalType: vitalType!)
    }
}

