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
                date: Date = DateUtils.getNowRoundedToNearest15(),
                timezone: TimeZone = TimeZone.current,
                notes: String? = nil) -> LogEntry? {
        let coreDataObject = TaichoContainer.container.persistenceController.createNewObject(objectName: LogEntry.objectName)
        guard let typedObject = coreDataObject as? LogEntry else {
            Log.assert("Object of incorrect type was created: " + String(describing: coreDataObject))
            return nil
        }
        typedObject.name = name
        typedObject.productivityLevel = productivityLevel
        typedObject.time = DateUtils.getDateRoundedToNearest15(date)
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
        return TaichoContainer.container.persistenceController.getAllObjects(LogEntry.objectName, objectType: LogEntry.self)
    }

    /**
     Deletes the given log entry.
     */
    func delete(_ logEntry: LogEntry) {
        delete([logEntry])
    }

    /**
     Deletes the given entries.
     */
    func delete(_ logEntries: [LogEntry]) {
        TaichoContainer.container.persistenceController.delete(logEntries)
    }

    /**
     Returns all log entries whose names contain the given string value.
     */
    func search(name nameString: String? = nil, date: Date? = nil) -> [LogEntry] {
        var queryString = ""
        var args: [Any] = []
        if let nameString = nameString, nameString.count > 0 {
            queryString += "\(LogEntry.nameKey) LIKE %@"
            args.append(nameString)
        }
        if let date = date {
            guard let startOfDate = DateUtils.getStartOfDay(for: date),
                  let endOfDate = DateUtils.getEndOfDay(for: date) else {
                      Log.assert("Failed to get start and end from date")
                      return []
                  }
            if queryString.count > 0 {
                queryString += " AND "
            }
            queryString += "(\(LogEntry.timeKey) >= %@) AND (\(LogEntry.timeKey) < %@)"
            args += [startOfDate as NSDate, endOfDate as NSDate]
        }
        let predicate = NSPredicate(format: queryString, argumentArray: args)
        return TaichoContainer.container.persistenceController.getAllObjects(LogEntry.objectName, objectType: LogEntry.self, predicate: predicate)
    }
    
}
