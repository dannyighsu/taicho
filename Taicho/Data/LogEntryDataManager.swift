//
//  LogEntryDataManager.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/16/22.
//

import Foundation
import CoreData

/**
 The data manager for LogEntry objects.
 */
class LogEntryDataManager: NSObject {
    
    /**
     Returns a new log entry for an activity that is starting now.
     */
    func createNewLogStartingNow(_ name: String, productivityLevel: ProductivityLevel, notes: String? = nil) -> LogEntry? {
        let coreDataObject = TaichoContainer.container.persistenceController.createNewObject(objectName: LogEntry.coreDataObjectType.objectName)
        guard let typedObject = coreDataObject as? CoreDataEntityObject else {
            Log.assert("Object of incorrect type was created: " + String(describing: coreDataObject))
            return nil
        }
        let logEntry = LogEntry(
            coreDataObject: typedObject,
            name: name,
            time: Date(),
            timezone: TimeZone.current,
            productivityLevel: productivityLevel,
            notes: notes)
        logEntry.persistCoreData()
        return logEntry
    }
    
    /**
     Returns a log entry created with the given preset's default values.
     */
    func createLogEntry(with preset: LogEntryPreset) -> LogEntry? {
        return createNewLogStartingNow(preset.name, productivityLevel: preset.productivityLevel)
    }
    
    /**
     Gets log entries for the given page size and offset.
     */
    func getAllLogEntries() -> [LogEntry] {
        let result = TaichoContainer.container.persistenceController.getAllObjects(LogEntry.coreDataObjectType.objectName)
        return result.map({ return LogEntry($0) }).compactMap({ $0 })
    }
    
}
