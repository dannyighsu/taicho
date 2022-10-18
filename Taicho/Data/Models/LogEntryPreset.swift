//
//  LogEntryPreset.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/15/22.
//

import Foundation
import CoreData

/**
 A user-defined preset that templatizes commonly repeated log entries.
 */
class LogEntryPreset: NSObject, TaichoEntity {
    
    static var coreDataObjectType: CoreDataEntityObject.Type {
        return CoreDataObject.self
    }
    fileprivate static let nameKey = "name"
    fileprivate static let productivityKey = "productivity"
    
    var coreDataObject: CoreDataEntityObject
    
    /**
     The name of the log entry. This is a human-readable string meant to identify the activity this log captures.
     */
    let name: String
    
    /**
     The productivity level of the entry.
     */
    let productivityLevel: ProductivityLevel
    
    required init(coreDataObject: CoreDataEntityObject, name: String, productivityLevel: ProductivityLevel) {
        self.coreDataObject = coreDataObject
        self.name = name
        self.productivityLevel = productivityLevel
        super.init()
    }
    
    convenience init?(_ managedObject: NSManagedObject) {
        guard let coreDataObject = managedObject as? CoreDataObject else {
            Log.assert("Incorrect core data object type passed in: \(managedObject)")
            return nil
        }
        guard let name = coreDataObject.value(forKey: LogEntryPreset.nameKey) as? String,
              let productivityString = coreDataObject.value(forKey: LogEntryPreset.productivityKey) as? String,
              let productivityLevel = ProductivityLevel(rawValue: productivityString) else {
            Log.assert("Failed to initialize with core data object!")
            return nil
        }
        self.init(coreDataObject: coreDataObject, name: name, productivityLevel: productivityLevel)
    }
    
    // MARK: - Methods
    
    func persistCoreData() {
        coreDataObject.setValue(name, forKey: LogEntryPreset.nameKey)
        coreDataObject.setValue(productivityLevel.rawValue, forKey: LogEntryPreset.productivityKey)
    }
    
}

// MARK: - CoreData

@objc(LogEntryPresetCoreDataObject)
fileprivate class CoreDataObject: NSManagedObject, CoreDataEntityObject {
    
    static var objectName: String {
        return "LogEntryPresetCoreDataObject"
    }
    
    @NSManaged var name: String
    @NSManaged var productivityLevel: String
    
    /**
     An entity description to be used by CoreData.
     */
    static var entityDescription: NSEntityDescription {
        let entity = NSEntityDescription()
        let nameAttribute = EntityField(name: LogEntryPreset.nameKey, type: String.self, isUnique: true)
        let productivityAttribute = EntityField(name: LogEntryPreset.productivityKey, type: String.self)

        entity.properties = [nameAttribute.propertyDescription, productivityAttribute.propertyDescription]
        entity.name = objectName
        entity.managedObjectClassName = objectName
        return entity
    }
    
}
