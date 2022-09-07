//
//  CoreDataRepository.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 4/27/21.
//

import Foundation
import CoreData

enum CoreDataError: Error {
    case invalidManagedObjectType
}

class CoreDataRepository<T: NSManagedObject> {
    typealias Entity = T

    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func get(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> Result<[Entity], Error> {

        let fetchRequest = Entity.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            // Perform the fetch request
            if let fetchResults = try managedObjectContext.fetch(fetchRequest) as? [Entity] {
                return .success(fetchResults)
            } else {
                return .failure(CoreDataError.invalidManagedObjectType)
            }
        } catch {
            return .failure(error)
        }
    }

    func create(entityType: String) -> Result<Entity, Error> {
        let className = String(describing: entityType)
        guard let managedObject = NSEntityDescription.insertNewObject(forEntityName: className, into: managedObjectContext) as? Entity else {
            return .failure(CoreDataError.invalidManagedObjectType)
        }
        return .success(managedObject)
    }

    func delete(entity: Entity) -> Result<Bool, Error> {
        managedObjectContext.delete(entity)
        return .success(true)
    }
}
