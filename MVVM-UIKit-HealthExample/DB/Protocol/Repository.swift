//
//  Repository.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/18/21.
//

import Foundation

protocol Repository {
    associatedtype EntityObject: Entity
    
    func getAll(where predicate: NSPredicate?, numberOfRows: Int) throws -> [EntityObject]
    func insert(item: EntityObject) throws
    func update(item: EntityObject) throws
    func delete(item: EntityObject) throws
}

extension Repository {
    func getAll() -> [EntityObject] {
        return try! getAll(where: nil, numberOfRows: 10)
    }
}

public protocol Entity {
    associatedtype StoreType: Storable
    
    func toStorable() -> StoreType
}

public protocol Storable {
    associatedtype EntityObject: Entity
    
    var model: EntityObject { get }
    var uuid: String { get }
}
