//
//  EntityField.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/15/22.
//

import Foundation
import CoreData

/**
 Generic implementation of a CoreData field property
 */
class EntityField {
    
    public let name: String
    public let type: Any.Type
    public let isOptional: Bool
    public let isUnique: Bool
    public let isIndexed: Bool
    
    public init(
        name: String,
        type: Any.Type,
        isOptional: Bool = false,
        isUnique: Bool = false,
        isIndexed: Bool = false
    ) {
        self.name = name
        self.type = type
        self.isOptional = isOptional
        self.isUnique = isUnique
        self.isIndexed = isIndexed
    }
    
    lazy var propertyDescription: NSPropertyDescription = {
        let property: NSPropertyDescription
        let attribute: NSAttributeDescription = NSAttributeDescription()
        if type == Bool.self {
            attribute.attributeType = .booleanAttributeType
        } else if type == String.self {
            attribute.attributeType = .stringAttributeType
        } else if type == Int.self {
            attribute.attributeType = .integer64AttributeType
        } else if type == Double.self {
            attribute.attributeType = .doubleAttributeType
        } else if type == Date.self {
            attribute.attributeType = .dateAttributeType
        } else {
            Log.assert("Unknown type found.")
        }
        attribute.isOptional = isOptional
        property = attribute
        property.name = name
        return property
    }()
    
}
