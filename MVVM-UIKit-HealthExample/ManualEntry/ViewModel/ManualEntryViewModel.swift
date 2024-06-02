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

    private var lastReading: Double = 0.0
    private var newReading: Double = 0.0


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
        lastReading = value
        if lastReading != newReading {
            newReading = lastReading
            print(newReading)
        }
    }

    func saveVitalReading(readingType: ReadingType, closure: @escaping () -> Void) {
        let timeStamp = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MM-dd-yyyy hh:mm a"
        let dateString = formatter.string(from: timeStamp)
        let readingTypeString = readingType.description
        var reading: String = ""

        var readingList = [Dictionary<String,String>]()

        switch readingType {
        case .glucode:
            reading = String(Int(newReading))
            readingList.insert(["createdTime": dateString, "glucose": reading], at: 0)
        case .weightScale:
            reading = String(Int(newReading))
            readingList.insert(["createdTime": dateString, "weight": reading], at: 0)
        case .thermometer:
            reading = String(format: "%.1f", newReading)
            readingList.insert(["createdTime": dateString, "temperature": reading], at: 0)
        }
        let vitalReading = VitalReading(createdTimestamp: dateString, readingValue1: reading, readingValue2: "", readingValue3: "", isBluetooth: false, vitalType: readingTypeString)
        insertVitalReading(vitalReading: vitalReading)

        let dashboardViewModel = DashboardViewModel()
        dashboardViewModel.updateLastVitalReadingToDevice(deviceType: readingTypeString, readingList: readingList)

        closure()
    }
}
