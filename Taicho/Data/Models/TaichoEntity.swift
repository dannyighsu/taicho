//
//  TaichoEntity.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/16/22.
//

import Foundation
import RxSwift

/**
 A Taicho entity data object.
 
 Taicho entities are also responsible for maintaining a strong reference to their own core data objects.
 When a Taicho entity is modified, it should pass the underlying core data object to the new copy as well.
 */
protocol TaichoEntity {
    
    static var coreDataObjectType: CoreDataEntityObject.Type { get }
    
    var coreDataObject: CoreDataEntityObject { get }
    
    /**
     Persists this TaichoEntity's data into the underlying core data object. Note that this does *not* save
     the overall model view context itself, which must be done separately in order for the changes to persist.
     */
    func persistCoreData()
    
}
