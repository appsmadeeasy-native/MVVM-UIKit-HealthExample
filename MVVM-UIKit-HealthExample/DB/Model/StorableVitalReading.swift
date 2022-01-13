//
//  StorableVitalReading.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/22/21.
//

import Foundation
import RealmSwift

extension VitalReading: Entity {
    
    private var storableVitalReading: StorableVitalReading {
        let realmVitalReading = StorableVitalReading()
        realmVitalReading.vitalType = vitalType
        realmVitalReading.createdTimestamp = createdTimestamp
        realmVitalReading.readingValue1 = readingValue1
        realmVitalReading.readingValue2 = readingValue2
        realmVitalReading.readingValue3 = readingValue3
        realmVitalReading.isBluetooth = isBluetooth
        realmVitalReading.uuid = NSUUID().uuidString
        return realmVitalReading
    }
    
    func toStorable() -> StorableVitalReading {
        return storableVitalReading
    }
}

class StorableVitalReading: Object, Storable {
    
    @objc dynamic var vitalType: String = ""
    @objc dynamic var createdTimestamp: String = ""
    @objc dynamic var readingValue1: String = ""
    @objc dynamic var readingValue2: String = ""
    @objc dynamic var readingValue3: String = ""
    @objc dynamic var isBluetooth: Bool = false
    @objc dynamic var uuid: String = ""
    
    var model: VitalReading
    {
        get {
            return VitalReading(createdTimestamp: createdTimestamp, readingValue1: readingValue1, readingValue2: readingValue2, readingValue3: readingValue3, isBluetooth: isBluetooth, vitalType: vitalType)
        }
    }
}
