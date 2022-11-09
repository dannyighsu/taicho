//
//  LogEntry.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/15/22.
//

import Foundation
import CoreData
import Combine

/**
 A semantic measurement of the productivity of the activity.
 */
enum ProductivityLevel: String, CaseIterable {

    static let defaultProductivity: ProductivityLevel = .high
    
    private static let highProductivityDisplayString = "High"
    private static let medProductivityDisplayString = "Medium"
    private static let lowProductivityDisplayString = "Low"
    private static let noProductivityDisplayString = "Not Productive"
    
    case high
    case medium
    case low
    case none
    
    var displayName: String {
        switch self {
        case .high:
            return Self.highProductivityDisplayString
        case .medium:
            return Self.medProductivityDisplayString
        case .low:
            return Self.lowProductivityDisplayString
        case .none:
            return Self.noProductivityDisplayString
        }
    }
    
    static func value(from displayString: String) -> Self? {
        switch displayString {
        case highProductivityDisplayString:
            return .high
        case medProductivityDisplayString:
            return .medium
        case lowProductivityDisplayString:
            return .low
        case noProductivityDisplayString:
            return ProductivityLevel.none
        default:
            return nil
        }
    }
    
}

/**
 Represents a single entry in the log, representing one activity the user engaged in.
 */
@objc(LogEntry)
class LogEntry: NSManagedObject, TaichoEntity {

    // MARK: - Class Properties
    
    static var objectName: String {
        return "LogEntry"
    }

    fileprivate static let nameKey = "storedName"
    fileprivate static let timeKey = "storedTime"
    fileprivate static let timezoneKey = "storedTimezone"
    fileprivate static let productivityKey = "storedProductivityLevel"
    fileprivate static let notesKey = "storedNotes"

    // MARK: - Properties

    /**
     The name of the log entry. This is a human-readable string meant to identify the activity this log captures.
     */
    @NSManaged private var storedName: String
    /**
     The time that the activity this log entry represents commenced.
     */
    @NSManaged private var storedTime: Date
    /**
     The timezone that this entry was created in.
     */
    @NSManaged private var storedTimezone: String
    /**
     The productivity level of the entry.
     */
    @NSManaged private var storedProductivityLevel: String
    /**
     Custom notes the user may add to the entry.
     */
    @NSManaged private var storedNotes: String?

    var name: String {
        get {
            return (value(forKey: LogEntry.nameKey) as? String).assertIfNil() ?? ""
        }
        set {
            setValue(newValue, forKey: LogEntry.nameKey)
        }
    }
    var time: Date {
        get {
            return (value(forKey: LogEntry.timeKey) as? Date).assertIfNil() ?? Date()
        }
        set {
            setValue(newValue, forKey: LogEntry.timeKey)
        }
    }
    var timezone: TimeZone {
        get {
            guard let timezoneIdentifier = (value(forKey: LogEntry.timezoneKey) as? String),
                  let timezone = TimeZone(identifier: timezoneIdentifier) else {
                      Log.assert("Failed to serialize timezone.")
                      return TimeZone.current
                  }
            return timezone
        }
        set {
            setValue(newValue.identifier, forKey: LogEntry.timezoneKey)
        }
    }
    var productivityLevel: ProductivityLevel {
        get {
            guard let productivityString = value(forKey: LogEntry.productivityKey) as? String,
                  let productivityLevel = ProductivityLevel(rawValue: productivityString) else {
                      Log.assert("Failed to serialize productivity level.")
                      return .none
                  }
            return productivityLevel
        }
        set {
            setValue(newValue.rawValue, forKey: LogEntry.productivityKey)
        }
    }
    var notes: String? {
        get {
            return (value(forKey: LogEntry.notesKey) as? String) ?? ""
        }
        set {
            setValue(newValue, forKey: LogEntry.notesKey)
        }
    }

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
