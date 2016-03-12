//
//  CoreDataStack.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 2/2/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
        
        var context:NSManagedObjectContext!
        var psc:NSPersistentStoreCoordinator
        var model:NSManagedObjectModel
        var store:NSPersistentStore?
        
        init() {
            
            let bundle = NSBundle.mainBundle()
            let modelURL =
            bundle.URLForResource("MinimalKmiles", withExtension:"momd")
            model = NSManagedObjectModel(contentsOfURL: modelURL!)!
            
            psc = NSPersistentStoreCoordinator(managedObjectModel:model)
            
            context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            context.persistentStoreCoordinator = psc
            
            let documentsURL = applicationDocumentsDirectory()
            let storeURL =
            documentsURL.URLByAppendingPathComponent("MinimalKmiles")
            
            let options =
            [NSMigratePersistentStoresAutomaticallyOption: true]
            
            var error: NSError? = nil
            do {
                store = try psc.addPersistentStoreWithType(NSSQLiteStoreType,
                    configuration: nil,
                    URL: storeURL,
                    options: options)
            } catch let error1 as NSError {
                error = error1
                store = nil
            }
            
            if store == nil {
                print("Error adding persistent store: \(error)")
                abort()
            }
            
        }
        
        func saveContext() {
            
            var error: NSError? = nil
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                    print("Could not save: \(error), \(error?.userInfo)")
                }
            }
            
        }
        
        func applicationDocumentsDirectory() -> NSURL {
            
            let fileManager = NSFileManager.defaultManager()
            
            let urls = fileManager.URLsForDirectory(.DocumentDirectory,
                inDomains: .UserDomainMask) as Array<NSURL>
            
            return urls[0]
        }
}