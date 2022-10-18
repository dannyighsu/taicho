//
//  TaichoContainer.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/14/22.
//

import Foundation
import UIKit

/**
 This is the master container for Taicho app state.
 */
class TaichoContainer {
    
    static let container: TaichoContainer = TaichoContainer()
    
    lazy var persistenceController = PersistenceController(errorHandlerController: UIApplication.shared.keyWindow?.rootViewController)
    
    lazy var logEntryDataManager = LogEntryDataManager()
    
    lazy var logEntryPresetDataManager = LogEntryDataManager()
    
}
