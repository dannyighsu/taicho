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
@objc(LogEntryPreset)
class LogEntryPreset: NSManagedObject, TaichoEntity {

    private static let nameKey = "name"
    private static let productivityKey = "productivity"
    private static let iconKey = "icon"


    static var objectName: String {
        return "LogEntryPreset"
    }

    /**
     The name of the log entry. This is a human-readable string meant to identify the activity this log captures.
     */
    @NSManaged private var storedName: String
    /**
     The productivity level of the entry.
     */
    @NSManaged private var storedProductivityLevel: String
    /**
     The graphical representation of the entry.
     */
    @NSManaged private var storedIcon: String

    var name: String {
        get {
            return (value(forKey: LogEntryPreset.nameKey) as? String).assertIfNil() ?? ""
        }
        set {
            setValue(newValue, forKey: LogEntryPreset.nameKey)
        }
    }
    var productivityLevel: ProductivityLevel {
        get {
            guard let productivityString = value(forKey: LogEntryPreset.productivityKey) as? String,
                  let productivityLevel = ProductivityLevel(rawValue: productivityString) else {
                      Log.assert("Failed to serialize productivity level.")
                      return .none
                  }
            return productivityLevel
        }
        set {
            setValue(newValue.rawValue, forKey: LogEntryPreset.productivityKey)
        }
    }
    var icon: String {
        get {
            return (value(forKey: LogEntryPreset.iconKey) as? String).assertIfNil() ?? ""
        }
        set {
            setValue(newValue, forKey: LogEntryPreset.iconKey)
        }
    }

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
