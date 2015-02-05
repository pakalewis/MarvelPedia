//
//  CoreDataManager.swift
//  MarvelPedia
//
//  Created by Alex G on 20.10.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    // MARK: Class Properties
    /**
    Returns a singleton object of CoreDataManager type.
    */
    class var manager: CoreDataManager {
        struct Struct {
            static var token: dispatch_once_t = 0
            static var instance: CoreDataManager! = nil
        }
        dispatch_once(&Struct.token, { () -> Void in
            Struct.instance = CoreDataManager()
        })
        return Struct.instance
    }
    
    // MARK: Public Methods
    
    /**
    Creates, configures, and returns an instance of the class for the entity with a name from a given class.
    
    :param: entityClass The class of the entity to be created.
    
    :return: A new, autoreleased, fully configured instance of the class for the entity named after entityClass name. Returns nil if an attempt to get the entity name fails.
    */
    
    func newObjectForEntityClass(entityClass: AnyClass) -> AnyObject? {
        let entityName = entityNameFromClass(entityClass)
        if entityName == nil {
            return nil
        }
        
        return NSEntityDescription.insertNewObjectForEntityForName(entityName!, inManagedObjectContext: managedObjectContext!)
    }
    
    /**
    Returns an array of objects that meet the criteria specified by a given predicate format.
    
    :param: entityClass The class of the entity to be created. Call classForCoder() on a needed class, if you provide predicateFormat parameter.
    :param: predicateFormat The format string for the new predicate.
    :param: argList The arguments to substitute into predicateFormat. Use NSObjects for these arguments.
    
    :return: An array of objects that meet the criteria specified by a given predicate format. Returns nil if an attempt to get the entity name fails.
    */
    
    func fetchObjectsWithEntityClass(entityClass: AnyClass, predicateFormat: String? = nil, _ argList: CVarArgType...) -> [AnyObject]? {
        let entityName = entityNameFromClass(entityClass)
        if entityName == nil {
            return nil
        }
        
        let fetchRequest = NSFetchRequest(entityName: entityName!)
        if predicateFormat != nil {
            let args = getVaList(argList)
            fetchRequest.predicate = NSPredicate(format: predicateFormat!, arguments: args)
        }
        
        var error: NSError?
        let retVal = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error)
        
        if let error = error {
            println("Error fetching \(fetchRequest.predicate?.predicateFormat): \(error.localizedDescription)")
        }
        
        return retVal
    }
    
    func countObjectsWithEntityClass(entityClass: AnyClass, predicateFormat: String? = nil, _ argList: CVarArgType...) -> Int {
        let entityName = entityNameFromClass(entityClass)
        if entityName == nil {
            return 0
        }
        
        let fetchRequest = NSFetchRequest(entityName: entityName!)
        if predicateFormat != nil {
            let args = getVaList(argList)
            fetchRequest.predicate = NSPredicate(format: predicateFormat!, arguments: args)
        }
        
        var error: NSError?
        let retVal = managedObjectContext?.countForFetchRequest(fetchRequest, error: &error)
        
        if let error = error {
            println("Error fetching \(fetchRequest.predicate?.predicateFormat): \(error.localizedDescription)")
        }
        
        return retVal == nil ? 0 : retVal!
    }
    
    func deleteObject(object: NSManagedObject) {
        managedObjectContext?.deleteObject(object)
    }
    
    /**
    Attempts to save the main managed object context asynchronously. Crashes on error.
    */
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

    // MARK: Private Methods
    private func entityNameFromClass(entityClass: AnyClass) -> String? {
        let retVal = NSStringFromClass(entityClass).componentsSeparatedByString(".").last
        if retVal == nil {
            println("Error. Couldn't get entity name from class \(NSStringFromClass(entityClass))")
        }
        
        return retVal
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("MarvelPedia", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("MarvelPedia.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
}