//
//  TaichoEntityDataManager.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/28/22.
//

import Foundation
import Combine
import CoreData

/**
 A class managing the data of one Taicho entity object type.

 This manager will begin to listen for updates to any objects of its entity type, and provide
 consumers updates via the various publishers.
 */
class TaichoEntityDataManager<Entity: TaichoEntity>: NSObject {

    /**
     Publishes updates to any changed individual log entries. Consumers can listen to this
     to receive all log entry object updates.
     */
    var objectUpdatePublisher: AnyPublisher<[Entity], Never> {
        return objectUpdateSubject.eraseToAnyPublisher()
    }
    private let objectUpdateSubject = PassthroughSubject<[Entity], Never>()

    /**
     Publishes an update when a log entry is created.
     */
    var objectInsertedPublisher: AnyPublisher<[Entity], Never> {
        return objectInsertedSubject.eraseToAnyPublisher()
    }
    private let objectInsertedSubject = PassthroughSubject<[Entity], Never>()

    /**
     Publishes an update when a log entry is deleted.
     */
    var objectDeletedPublisher: AnyPublisher<[Entity], Never> {
        return objectDeletedSubject.eraseToAnyPublisher()
    }
    private let objectDeletedSubject = PassthroughSubject<[Entity], Never>()

    override init() {
        super.init()

        NotificationCenter.default.addObserver(
            forName: NSManagedObjectContext.didChangeObjectsNotification,
            object: nil,
            queue: OperationQueue.main) { notification in
                let objectMapper = { (object: NSManagedObject) -> Entity? in
                    return object as? Entity
                }
                if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
                    self.objectUpdateSubject.send(updatedObjects.compactMap(objectMapper))
                }
                if let addedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
                    self.objectInsertedSubject.send(addedObjects.compactMap(objectMapper))
                }
                if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> {
                    self.objectDeletedSubject.send(deletedObjects.compactMap(objectMapper))
                }
            }
    }

}
