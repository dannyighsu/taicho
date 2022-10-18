//
//  CoreDataEntityObject.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/15/22.
//

import Foundation
import CoreData

/**
 Represents a core data entity object that can be managed by CoreData.
 */
protocol CoreDataEntityObject: NSManagedObject {
    
    /**
     The object's name. Will be used to key the object type uniquely.
     */
    static var objectName: String { get }
    /**
     An entity description for this object type
     */
    static var entityDescription: NSEntityDescription { get }
    
}
