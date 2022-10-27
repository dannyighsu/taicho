//
//  LogEntryPresetDataManager.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/16/22.
//

import Foundation

/**
 The data manager for LogEntryPreset objects.
 */
class LogEntryPresetDataManager {

    /**
     Returns a log entry preset created with the given values.
     */
    func create(name: String, productivity: ProductivityLevel, icon: String) -> LogEntryPreset? {
        let coreDataObject = TaichoContainer.container.persistenceController.createNewObject(objectName: LogEntryPreset.objectName)
        guard let typedObject = coreDataObject as? LogEntryPreset else {
            Log.assert("Object of incorrect type was created: " + String(describing: coreDataObject))
            return nil
        }
        typedObject.name = name
        typedObject.productivityLevel = productivity
        typedObject.icon = icon

        return typedObject
    }

    /**
     Gets log entries for the given page size and offset.
     */
    func getAll() -> [LogEntryPreset] {
        let result = TaichoContainer.container.persistenceController.getAllObjects(LogEntryPreset.objectName)
        return result.compactMap { ($0 as? LogEntryPreset).assertIfNil() }
    }
    
}
