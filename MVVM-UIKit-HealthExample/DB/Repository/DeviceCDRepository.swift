//
//  DeviceCDRepository.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 4/30/21.
//

import Foundation
import CoreData

protocol DeviceRepositoryInterface {

    func getDevices(predicate: NSPredicate?) -> Result<[Device], Error>
    func updateDeviceLastReadingByDeviceType(deviceType: String, vitalReading: Dictionary<String,String>) -> Result<Device, Error>
}

class DeviceCDRepository {

    private let repositoryD: CoreDataRepository<DeviceMO>
    private let managedObjectContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.repositoryD = CoreDataRepository<DeviceMO>(managedObjectContext: context)
        self.managedObjectContext = context
    }
}

extension DeviceCDRepository: DeviceRepositoryInterface {

    @discardableResult func getDevices(predicate: NSPredicate?) -> Result<[Device], Error> {
        let result = repositoryD.get(predicate: predicate, sortDescriptors: nil)
        switch result {
        case .success(let DeviceMO):
            // Transform the NSManagedObject objects to domain objects
            let devices = DeviceMO.map { DeviceMO -> Device in
                return DeviceMO.toDomainModel()
            }
            
            return .success(devices)
        case .failure(let error):
            return .failure(error)
        }
    }

    @discardableResult func updateDeviceLastReadingByDeviceType(deviceType: String,
                                  vitalReading: Dictionary<String,String>) -> Result<Device, Error> {
        let result = repositoryD.get(predicate: NSPredicate(format: "deviceType = %@", deviceType), sortDescriptors: nil)
        switch result {
        case .success(let devices):
            let deviceMO = devices.first
            deviceMO?.lastReadingTimestamp =  vitalReading["createdTime"]!
            
            switch deviceMO?.deviceType {
            case "Glucometer":
                deviceMO?.lastReadingValue1 = vitalReading["glucose"]!
            case "Blood Pressure":
                deviceMO?.lastReadingValue1 = vitalReading["systolic"]!
                deviceMO?.lastReadingValue2 = vitalReading["diastolic"]!
                deviceMO?.lastReadingValue3 = vitalReading["bmp"]!
            case "Weight Scale":
                deviceMO?.lastReadingValue1 = vitalReading["weight"]!
            case "Thermometer":
                deviceMO?.lastReadingValue1 = vitalReading["temperature"]!
            case "Pulse Oximeter":
                deviceMO?.lastReadingValue1 = vitalReading["spo2"]!
                deviceMO?.lastReadingValue2 = vitalReading["bmp"]!
            default:
                print("No value")
            }
            do {
                try managedObjectContext.save()
            } catch {
                return .failure(CoreDataError.invalidManagedObjectType)
            }
            
            return .success(deviceMO!.toDomainModel())
        case .failure(let error):
            return .failure(error)
        }
    }
}
