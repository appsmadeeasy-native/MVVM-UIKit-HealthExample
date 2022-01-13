//
//  Device.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/19/21.
//

import Foundation

struct Device: Codable {
    var deviceType: String
    var serviceUUID: String
    var characteristicUUID: String
    var characteristicUUID2: String
    var characteristicUUID3: String
    var characteristicUUID4: String
    var lastReadingValue1: String
    var lastReadingValue2: String
    var lastReadingValue3: String
    var lastReadingTimestamp: String
    var readingScale: String
}
