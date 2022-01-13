//
//  RepositoryManager.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 1/5/22.
//

import Foundation

class RepositoryManager: NSObject {
    
    private var database: String?
    var repRealmForDevice: RealmRepository<Device>?
    var repRealmForVitalReading: RealmRepository<VitalReading>?
    var repCoreDataForDevice: DeviceCDRepository?
    var repCoreDataForVitalReading: VitalReadingCDRepository?
    private var entityType: String?
    
    
    init(entityType: String) {
        self.entityType = entityType
        let defaults = UserDefaults.standard
        database = defaults.string(forKey: "database")
        if database == DatabaseEnum.coredata.rawValue {
            switch(entityType) {
            case "Device":
                repCoreDataForDevice = DeviceCDRepository(context: CoreDataContextProvider.sharedInstance.managedObjectContext)
            case "VitalReading":
                repCoreDataForVitalReading = VitalReadingCDRepository(context: CoreDataContextProvider.sharedInstance.managedObjectContext)
            default:
                print("Entity passed is unknown!")
            }
        } else {
            switch(entityType) {
            case "Device":
                repRealmForDevice = RealmRepository()
            case "VitalReading":
                repRealmForVitalReading = RealmRepository()
            default:
                print("Entity passed is unknown!")
            }
        }
    }
    
    
}
