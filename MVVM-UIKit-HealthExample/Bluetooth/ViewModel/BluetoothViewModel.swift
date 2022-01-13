//
//  BluetoothViewModel.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/22/21.
//

import Foundation
import RealmSwift

class BluetoothViewModel {
    
    private var repositoryR: RealmRepository<VitalReading>?
    private var repositoryVR: VitalReadingCDRepository?
    private var database: String?

    
    init() {
        let defaults = UserDefaults.standard
        database = defaults.string(forKey: "database")

        if database == DatabaseEnum.coredata.rawValue {
            repositoryVR = VitalReadingCDRepository(context: CoreDataContextProvider.sharedInstance.managedObjectContext)
        } else {
            repositoryR = RealmRepository()
        }
    }
    
    func insertVitalReadingList(
        deviceType: String,
        readingList: [Dictionary<String,String>],
        isBluetooth: Bool
    ) {
        for readingItem in readingList {
            var vitalReading: VitalReading?
            
            switch deviceType {
            case "Glucometer":
                vitalReading = VitalReading(createdTimestamp: readingItem["createdTime"]!, readingValue1: readingItem["glucose"]!, readingValue2: "", readingValue3: "", isBluetooth: isBluetooth, vitalType: deviceType)
            case "Blood Pressure":
                vitalReading = VitalReading(createdTimestamp: readingItem["createdTime"]!, readingValue1: readingItem["systolic"]!, readingValue2: readingItem["diastolic"]!, readingValue3: readingItem["bmp"]!, isBluetooth: isBluetooth, vitalType: deviceType)
            case "Weight Scale":
                vitalReading = VitalReading(createdTimestamp: readingItem["createdTime"]!, readingValue1: readingItem["weight"]!, readingValue2: "", readingValue3: "", isBluetooth: isBluetooth, vitalType: deviceType)
            case "Thermometer":
                vitalReading = VitalReading(createdTimestamp: readingItem["createdTime"]!, readingValue1: readingItem["temperature"]!, readingValue2: "", readingValue3: "", isBluetooth: isBluetooth, vitalType: deviceType)
            case "Pulse Oximeter":
                vitalReading = VitalReading(createdTimestamp: readingItem["createdTime"]!, readingValue1: readingItem["spo2"]!, readingValue2: readingItem["bmp"]!, readingValue3: "", isBluetooth: isBluetooth, vitalType: deviceType)
            default:
                return
            }
            
            if let vitalReading = vitalReading {
                insertVitalReading(vitalReading: vitalReading)
            }
        }
    }
    
    func insertVitalReading(vitalReading: VitalReading) {
        let defaults = UserDefaults.standard
        database = defaults.string(forKey: "database")
        if database == DatabaseEnum.coredata.rawValue {
            repositoryVR!.insertReading(vitalReading: vitalReading)
        } else {
            try! repositoryR?.insert(item: vitalReading)
        }
    }
    
    func getVitalReadingsByType(vitalType: String, resultSet: ([VitalReading]) -> Void) {
        let defaults = UserDefaults.standard
        database = defaults.string(forKey: "database")
        if database == DatabaseEnum.coredata.rawValue {
            let vitalReadings = repositoryVR?.getReadings(predicate: NSPredicate(format: "vitalType = %@", vitalType))
            guard let readings = try! vitalReadings?.get() else { return }
            resultSet(readings)
        } else {
            let vitalReadings = repositoryR?.getAll(where: NSPredicate(format: "vitalType = %@", vitalType))
            resultSet(vitalReadings!)
        }
    }
}

