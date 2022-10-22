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
final class LogEntryDataManager: NSObject {

    /**
     Publishes updates to any changed log entries. Consumers can listen to this
     to receive all log entry object updates.
     */
    var publisher: AnyPublisher<LogEntry, Never> {
        return logEntrySubject.eraseToAnyPublisher()
    }
    private let logEntrySubject = PassthroughSubject<LogEntry, Never>()

    override required init() {
        super.init()

        NotificationCenter.default.addObserver(
            forName: NSManagedObjectContext.didChangeObjectsNotification,
            object: nil,
            queue: OperationQueue.main) { notification in
                guard let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<LogEntry> else {
                    return
                }

                updatedObjects.forEach {
                    self.logEntrySubject.send($0)
                }
            }
    }
    
    /**
     Returns a new log entry for an activity that is starting now.
     */
    func createNewLogStartingNow(_ name: String, productivityLevel: ProductivityLevel, notes: String? = nil) -> LogEntry? {
        let coreDataObject = TaichoContainer.container.persistenceController.createNewObject(objectName: LogEntry.objectName)
        guard let typedObject = coreDataObject as? LogEntry else {
            Log.assert("Object of incorrect type was created: " + String(describing: coreDataObject))
            return nil
        }
        typedObject.name = name
        typedObject.productivityLevel = productivityLevel
        typedObject.time = Date()
        typedObject.timezone = TimeZone.current
        typedObject.notes = notes

        return typedObject
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
        let result = TaichoContainer.container.persistenceController.getAllObjects(LogEntry.objectName)
        return result.compactMap { ($0 as? LogEntry).assertIfNil() }
    }
    
}
