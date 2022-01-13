//
//  RealmRepository.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/18/21.
//

import Foundation
import RealmSwift

class RealmRepository<RepositoryObject>: Repository
        where RepositoryObject: Entity,
        RepositoryObject.StoreType: Object {
    
    typealias RealmObject = RepositoryObject.StoreType
    
    private let realm: Realm

    init() {
        var config = Realm.Configuration.defaultConfiguration

        // Using the default directory, append to default.realm
        config.fileURL!.deleteLastPathComponent()
        config.fileURL!.appendPathComponent("bluetooth")
        config.fileURL!.appendPathExtension("realm")
        // Open the Realm with the configuration
        realm = try! Realm(configuration: config)
    }

    func getAll(where predicate: NSPredicate?, numberOfRows: Int = 10) -> [RepositoryObject] {
        var objects = realm.objects(RealmObject.self)

        if let predicate = predicate {
            objects = objects.filter(predicate).sorted(byKeyPath: "createdTimestamp", ascending: false)
        }
        let entities = objects.compactMap{ ($0).model as? RepositoryObject }
        return entities.enumerated().compactMap{ $0.offset < numberOfRows ? $0.element : nil }
    }

    func insert(item: RepositoryObject) throws {
        try realm.write {
            realm.add(item.toStorable())
        }
    }
    
    func updateDeviceByDeviceType(deviceType: String, vitalReading: Dictionary<String,String>) throws {
        let devices = realm.objects(StorableDevice.self).filter("deviceType = %@", deviceType)
        
        if let device = devices.first {
            try! realm.write {
                device.lastReadingTimestamp = vitalReading["createdTime"]!
                switch deviceType {
                case "Glucometer":
                    device.lastReadingValue1 = vitalReading["glucose"]!
                case "Blood Pressure":
                    device.lastReadingValue1 = vitalReading["systolic"]!
                    device.lastReadingValue2 = vitalReading["diastolic"]!
                    device.lastReadingValue3 = vitalReading["bmp"]!
                case "Weight Scale":
                    device.lastReadingValue1 = vitalReading["weight"]!
                case "Thermometer":
                    device.lastReadingValue1 = vitalReading["temperature"]!
                case "Pulse Oximeter":
                    device.lastReadingValue1 = vitalReading["spo2"]!
                    device.lastReadingValue2 = vitalReading["bmp"]!
                default:
                    return
                }
            }
        }
    }

    func update(item: RepositoryObject) throws {
        try delete(item: item)
        try insert(item: item)
    }

    func delete(item: RepositoryObject) throws {
        try realm.write {
            let predicate = NSPredicate(format: "uuid == %@", item.toStorable().uuid)
            if let productToDelete = realm.objects(RealmObject.self)
                .filter(predicate).first {
                realm.delete(productToDelete)
            }
        }
    }
}

