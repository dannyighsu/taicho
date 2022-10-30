//
//  LogEntryDataManager.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/16/22.
//

import Foundation
import CoreData
import Combine

/**
 The data manager for LogEntry objects.
 */
final class LogEntryDataManager: TaichoEntityDataManager<LogEntry> {
    
    /**
     Returns a new log entry for an activity. By default this will be a log entry
     that is starting now, in the current timezone.
     */
    func create(_ name: String,
                productivityLevel: ProductivityLevel,
                date: Date = Date(),
                timezone: TimeZone = TimeZone.current,
                notes: String? = nil) -> LogEntry? {
        let coreDataObject = TaichoContainer.container.persistenceController.createNewObject(objectName: LogEntry.objectName)
        guard let typedObject = coreDataObject as? LogEntry else {
            Log.assert("Object of incorrect type was created: " + String(describing: coreDataObject))
            return nil
        }
        typedObject.name = name
        typedObject.productivityLevel = productivityLevel
        typedObject.time = date
        typedObject.timezone = timezone
        typedObject.notes = notes

        return typedObject
    }
    
    /**
     Returns a log entry created with the given preset's default values.
     */
    func create(with preset: LogEntryPreset) -> LogEntry? {
        return create(preset.name, productivityLevel: preset.productivityLevel)
    }
    
    /**
     Gets log entries for the given page size and offset.
     */
    func getAll() -> [LogEntry] {
        let result = TaichoContainer.container.persistenceController.getAllObjects(LogEntry.objectName)
        return result.compactMap { ($0 as? LogEntry).assertIfNil() }
    }
    
}
