//
//  TaichoEntity.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/16/22.
//

import Foundation
import CoreData

/**
 A Taicho entity data object.
 
 Taicho entities are also responsible for maintaining a strong reference to their own core data objects.
 When a Taicho entity is modified, it should pass the underlying core data object to the new copy as well.
 */
protocol TaichoEntity: NSManagedObject {
    
    /**
     An entity description for this object type
     */
    static var entityDescription: NSEntityDescription { get }
    
}
