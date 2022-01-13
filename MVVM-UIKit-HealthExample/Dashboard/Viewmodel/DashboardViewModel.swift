//
//  DashboardViewModel.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/20/21.
//

import Foundation

enum DatabaseEnum: String {
    case coredata, realm
}

class DashboardViewModel {

    private var repositoryRealm: RealmRepository<Device>?
    private var repositoryCD: DeviceCDRepository?
    private var database: String?
    
    init() {
        let defaults = UserDefaults.standard
        database = defaults.string(forKey: "database")
        
        if database == DatabaseEnum.coredata.rawValue {
            repositoryCD = DeviceCDRepository(context: CoreDataContextProvider.sharedInstance.managedObjectContext)
        } else {
            repositoryRealm = RealmRepository()
        }
    }
    
    func getAllDevices() -> [Device] {
        if database == DatabaseEnum.coredata.rawValue {
            let devices = repositoryCD!.getDevices(predicate: nil)
            return try! devices.get()
        } else {
            return repositoryRealm!.getAll(where: nil)
        }
    }
    
    func getDevicesByDeviceType(deviceType: String) -> [Device] {
        var devices: [Device] = [Device]()
        if database == DatabaseEnum.coredata.rawValue {
            devices = try! repositoryCD?.getDevices(predicate: NSPredicate(format: "deviceType = %@", deviceType)).get() ?? [Device]()
        } else {
            devices = repositoryRealm!.getAll(where: NSPredicate(format: "deviceType = %@", deviceType))
        }
        return devices
    }

    func updateLastVitalReadingToDevice(
        deviceType: String,
        readingList: [Dictionary<String,String>]
    ) {
        if database == DatabaseEnum.coredata.rawValue {
            repositoryCD?.updateDeviceLastReadingByDeviceType(deviceType: deviceType, vitalReading: readingList.first!)
        } else {
            try! repositoryRealm!.updateDeviceByDeviceType(deviceType: deviceType, vitalReading: readingList.first!)
        }
        NotificationCenter.default.post(name: Notification.Name("didReceiveReloadNotification"), object: nil)
    }
}
