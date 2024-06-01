//
//  ManualEntryViewModel.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 12/27/21.
//

import Foundation

class ManualEntryViewModel {
    
    private let repositoryR: RealmRepository<VitalReading>?
    private let repositoryVR: VitalReadingCDRepository?
    private var database: String? = ""

    private var lastReading: Int = 0
    private var newReading: Int = 0


    init(with repo: RealmRepository<VitalReading>) {
        repositoryR = repo
        repositoryVR = nil
        let defaults = UserDefaults.standard
        database = defaults.string(forKey: "database")
    }
    
    init(with repo: VitalReadingCDRepository) {
        repositoryVR = repo
        repositoryR = nil
        let defaults = UserDefaults.standard
        database = defaults.string(forKey: "database")
    }
    
    func insertVitalReading(vitalReading: VitalReading) {
        if database == DatabaseEnum.coredata.rawValue {
            repositoryVR!.insertReading(vitalReading: vitalReading)
        } else {
            try! repositoryR?.insert(item: vitalReading)
        }
    }

    func setReadingValue(value: Double) {
        lastReading = Int(value)
        if lastReading != newReading {
            newReading = lastReading
            print(newReading)
        }
    }

    func saveVitalReading(deviceType: String, closure: @escaping () -> Void) {
        let timeStamp = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MM-dd-yyyy hh:mm a"
        let dateString = formatter.string(from: timeStamp)
        let vitalReading = VitalReading(createdTimestamp: dateString, readingValue1: String(newReading), readingValue2: "", readingValue3: "", isBluetooth: false, vitalType: deviceType)
        insertVitalReading(vitalReading: vitalReading)

        var readingList = [Dictionary<String,String>]()
        switch (deviceType) {
        case "Glucometer":
            readingList.insert(["createdTime": dateString, "glucose": String(newReading)], at: 0)
        case "Weight Scale":
            readingList.insert(["createdTime": dateString, "weight": String(newReading)], at: 0)
        case "Thermometer":
            readingList.insert(["createdTime": dateString, "temperature": String(newReading)], at: 0)
        default:
            print(String(newReading))
        }

        let dashboardViewModel = DashboardViewModel()
        dashboardViewModel.updateLastVitalReadingToDevice(deviceType: deviceType, readingList: readingList)

        closure()
    }
}
