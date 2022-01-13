//
//  BPVitalReading.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/22/21.
//

import Foundation

struct VitalReading : Codable, Hashable {
    var createdTimestamp: String
    var readingValue1: String
    var readingValue2: String
    var readingValue3: String
    var isBluetooth: Bool
    var vitalType: String
}
