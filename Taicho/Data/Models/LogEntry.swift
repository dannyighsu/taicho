//
//  LogEntry.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/15/22.
//

import Foundation
import CoreData

/**
 A semantic measurement of the productivity of the activity.
 */
enum ProductivityLevel: String {
    
    case high
    case medium
    case low
    case none
    
    var displayName: String {
        switch self {
        case .high:
            return "High"
        case .medium:
            return "Medium"
        case .low:
            return "Low"
        case .none:
            return "Not Productive"
        }
    }
    
}

/**
 Represents a single entry in the log, representing one activity the user engaged in.
 */
class LogEntry: NSObject, TaichoEntity {
    
    static var coreDataObjectType: CoreDataEntityObject.Type {
        return CoreDataObject.self
    }
    fileprivate static let nameKey = "name"
    fileprivate static let timeKey = "time"
    fileprivate static let timezoneKey = "timezone"
    fileprivate static let productivityKey = "productivity"
    fileprivate static let notesKey = "notes"
    
    var coreDataObject: CoreDataEntityObject
    
    /**
     The name of the log entry. This is a human-readable string meant to identify the activity this log captures.
     */
    let name: String
    
    /**
     The time that the activity this log entry represents commenced.
     */
    let time: Date
    
    /**
     The timezone that this entry was created in.
     */
    let timezone: TimeZone
    
    /**
     The productivity level of the entry.
     */
    let productivityLevel: ProductivityLevel
    
    /**
     Custom notes the user may add to the entry.
     */
    let notes: String?
    
    required init(coreDataObject: CoreDataEntityObject, name: String, time: Date, timezone: TimeZone, productivityLevel: ProductivityLevel, notes: String?) {
        self.coreDataObject = coreDataObject
        self.name = name
        self.time = time
        self.timezone = timezone
        self.productivityLevel = productivityLevel
        self.notes = notes
        super.init()
    }
    
    convenience init?(_ managedObject: NSManagedObject) {
        guard let coreDataObject = managedObject as? CoreDataObject else {
            Log.assert("Incorrect core data object type passed in: \(managedObject)")
            return nil
        }
        guard let name = coreDataObject.value(forKey: LogEntry.nameKey) as? String,
              let time = coreDataObject.value(forKey: LogEntry.timeKey) as? Date,
              let timezoneString = coreDataObject.value(forKey: LogEntry.timezoneKey) as? String,
              let timezone = TimeZone(identifier: timezoneString),
              let productivityString = coreDataObject.value(forKey: LogEntry.productivityKey) as? String,
              let productivityLevel = ProductivityLevel(rawValue: productivityString) else {
                  Log.assert("Failed to initalize with core data object!")
                  return nil
              }
        
        // Validate that optional fields do not have unexpected non-nil values.
        let notesValue = coreDataObject.value(forKey: LogEntry.notesKey)
        let notes = notesValue as? String
        guard notes == nil || notesValue == nil else {
            Log.assert("Invalid type found in field.")
            return nil
        }
        self.init(
            coreDataObject: coreDataObject,
            name: name,
            time: time,
            timezone: timezone,
            productivityLevel: productivityLevel,
            notes: notes)
    }
    
    // MARK: - Methods
    
    func persistCoreData() {
        coreDataObject.setValue(name, forKey: LogEntry.nameKey)
        coreDataObject.setValue(time, forKey: LogEntry.timeKey)
        coreDataObject.setValue(timezone.identifier, forKey: LogEntry.timezoneKey)
        coreDataObject.setValue(productivityLevel.rawValue, forKey: LogEntry.productivityKey)
        coreDataObject.setValue(notes, forKey: LogEntry.notesKey)
    }
    
}

// MARK: - CoreData

@objc(LogEntryCoreDataObject)
fileprivate class CoreDataObject: NSManagedObject, CoreDataEntityObject {
    
    static var objectName: String {
        return "LogEntryCoreDataObject"
    }
    
    @NSManaged var name: String
    @NSManaged var time: Date
    @NSManaged var timezone: String
    @NSManaged var productivityLevel: String
    @NSManaged var notes: String
    
    /**
     An entity description to be used by CoreData.
     */
    static var entityDescription: NSEntityDescription {
        let entity = NSEntityDescription()
        let nameAttribute = EntityField(name: LogEntry.nameKey, type: String.self)
        let timeAttribute = EntityField(name: LogEntry.timeKey, type: Date.self)
        let timezoneAttribute = EntityField(name: LogEntry.timezoneKey, type: String.self)
        let productivityAttribute = EntityField(name: LogEntry.productivityKey, type: String.self)
        let notesAttribute = EntityField(name: LogEntry.notesKey, type: String.self, isOptional: true)

        entity.properties = [
            nameAttribute.propertyDescription,
            timeAttribute.propertyDescription,
            timezoneAttribute.propertyDescription,
            productivityAttribute.propertyDescription,
            notesAttribute.propertyDescription
        ]
        entity.name = objectName
        entity.managedObjectClassName = objectName
        return entity
    }
    
}
