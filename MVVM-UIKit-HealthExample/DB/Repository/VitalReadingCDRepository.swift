//
//  VitalReadingCDRepository.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 12/24/21.
//

import Foundation
import CoreData

/// Protocol that describes a reading repository.
protocol VitalReadingRepositoryInterface {
    // Insert a reading
    func insertReading(vitalReading: VitalReading) -> Result<VitalReading, Error>
    // Get all readings using a predicate
    func getReadings(predicate: NSPredicate?, numberOfRows: Int) -> Result<[VitalReading], Error>
}

// VitalReading Repository class.
class VitalReadingCDRepository {
    // The Core Data VitalReading repository.
    private let repositoryVR: CoreDataRepository<VitalReadingMO>
    /// The NSManagedObjectContext instance to be used for performing the operations.
    private let managedObjectContext: NSManagedObjectContext

    /// Designated initializer
    /// - Parameter context: The context used for storing and quering Core Data.
    init(context: NSManagedObjectContext) {
        self.repositoryVR = CoreDataRepository<VitalReadingMO>(managedObjectContext: context)
        self.managedObjectContext = context
    }
}

extension VitalReadingCDRepository: VitalReadingRepositoryInterface {

    @discardableResult func getReadings(predicate: NSPredicate?, numberOfRows: Int = 10) -> Result<[VitalReading], Error> {
        let sortDescriptor = NSSortDescriptor(key: "createdTimestamp", ascending: false)
        let sortDescriptors = [sortDescriptor]
        let result = repositoryVR.get(predicate: predicate, sortDescriptors: sortDescriptors)
        switch result {
        case .success(let VitalReadingMO):
            // Transform the NSManagedObject objects to domain objects
            let vitalReadings = VitalReadingMO.map { VitalReadingMO -> VitalReading in
                return VitalReadingMO.toDomainModel()
            }
            
            return .success(vitalReadings.enumerated().compactMap{ $0.offset < numberOfRows ? $0.element : nil })
        case .failure(let error):
            // Return the Core Data error.
            return .failure(error)
        }
    }

    @discardableResult func insertReading(vitalReading: VitalReading) -> Result<VitalReading, Error> {
        let result = repositoryVR.create(entityType: "VitalReadingMO")
        switch result {
        case .success(let vitalReadingMO):
            vitalReadingMO.createdTimestamp = vitalReading.createdTimestamp
            vitalReadingMO.readingValue1 = vitalReading.readingValue1
            vitalReadingMO.readingValue2 = vitalReading.readingValue2
            vitalReadingMO.readingValue3 = vitalReading.readingValue3
            vitalReadingMO.isBluetooth = vitalReading.isBluetooth
            vitalReadingMO.vitalType = vitalReading.vitalType

            do {
                try managedObjectContext.save()
            } catch {
                return .failure(CoreDataError.invalidManagedObjectType)
            }
            return .success(vitalReadingMO.toDomainModel())
            
        case .failure(let error):
            // Return the Core Data error.
            return .failure(error)
        }
    }
}
