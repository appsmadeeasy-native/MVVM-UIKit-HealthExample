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
}
