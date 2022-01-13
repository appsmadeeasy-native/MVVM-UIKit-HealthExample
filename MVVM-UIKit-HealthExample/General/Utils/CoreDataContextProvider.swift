//
//  CoreDataContextProvider.swift
//  GenericRepositoryTest
//
//  Created by Syed Mahmud on 4/29/21.
//

import Foundation
import CoreData

class CoreDataContextProvider: NSObject {
    
    class var sharedInstance : CoreDataContextProvider {
        #if TESTING
            //For testing create and return a new instance which would allow us to inject dependency
            let sessionMgr =  CoreDataContextProvider()
            return sessionMgr

        #else
            struct CoreDataAccessSingleton {
                static let instance = CoreDataContextProvider()
            }
            return CoreDataAccessSingleton.instance
        #endif
    }
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.blah.ViewerTest" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "BluetoothModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("MVVM-UIKit-HealthExample.sqlite")
        if !FileManager.default.fileExists(atPath: url.path) {
            let sourceSqliteURLs = [Bundle.main.url(forResource: "MVVM-UIKit-HealthExample", withExtension: "sqlite"),
                Bundle.main.url(forResource: "MVVM-UIKit-HealthExample", withExtension: "sqlite-wal"),
                Bundle.main.url(forResource: "MVVM-UIKit-HealthExample", withExtension: "sqlite-shm")]
            
            let destSqliteURLs = [self.applicationDocumentsDirectory.appendingPathComponent("MVVM-UIKit-HealthExample.sqlite"),
                self.applicationDocumentsDirectory.appendingPathComponent("MVVM-UIKit-HealthExample.sqlite-wal"),
                self.applicationDocumentsDirectory.appendingPathComponent("MVVM-UIKit-HealthExample.sqlite-shm")]
            
            var error:NSError? = nil
            for index in 0...(sourceSqliteURLs.count - 1) {
                try! FileManager.default.copyItem(at: sourceSqliteURLs[index]!, to: destSqliteURLs[index])
            }
        }
        
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
                    let options = [ NSInferMappingModelAutomaticallyOption : true,
                                    NSMigratePersistentStoresAutomaticallyOption : true]
                    
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
