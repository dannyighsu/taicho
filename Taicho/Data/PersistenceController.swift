//
//  PersistenceController.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/14/22.
//

import CoreData
import UIKit

class PersistenceController {
    
    // MARK: - Core Data stack
    
    private let errorHandler: (NSError) -> Void
    
    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(
            name: "Taicho",
            managedObjectModel: dataModel)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                self.errorHandler(error)
            }
        })
        return container
    }()
    
    private lazy var dataModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()
        
        // Grab the entity descriptions of all objects that need to be registered.
        model.entities = ([LogEntry.self, LogEntryPreset.self] as [TaichoEntity.Type]).map { $0.entityDescription }
        return model
    }()
    
    // MARK: - Initialization
    
    init(errorHandlerController: UIViewController?) {
        self.errorHandler = { error in
            guard let errorHandlerController = errorHandlerController else {
                Log.error("Missing error handling controller.")
                return
            }
            errorHandlerController.present(
                UIUtils.getErrorAlert(error.description),
                animated: true,
                completion: nil)
        }
    }

    // MARK: - Methods

    /**
     Persists the current model's context.
     */
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                Log.assert("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /**
     Returns an object of the given object type.
     
     - objectName: The name of the CoreData object as registered with the view context.
     */
    func createNewObject(objectName: String) -> NSManagedObject {
        return NSEntityDescription.insertNewObject(
            forEntityName: objectName,
            into: persistentContainer.viewContext)
    }
    
    /**
     Returns all objects of the given object type.
     */
    func getAllObjects<Object: NSManagedObject>(_ objectName: String, objectType: Object.Type, predicate: NSPredicate? = nil, sortDescriptor: NSSortDescriptor? = nil) -> [Object] {
        let request = NSFetchRequest<Object>(entityName: objectName)
        request.predicate = predicate
        if let sortDescriptor = sortDescriptor {
            request.sortDescriptors = [sortDescriptor]
        }
        do {
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            Log.error("\(error)")
            return []
        }
    }

    /**
     Deletes all objects given.
     */
    func delete(_ objects: [NSManagedObject]) {
        objects.forEach {
            persistentContainer.viewContext.delete($0)
        }
    }
    
}
