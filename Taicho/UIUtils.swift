//
//  UIUtils.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/14/22.
//

import Foundation
import UIKit

class UIUtils {
    
    static func getAlert(_ errorMessage: String) -> UIAlertController {
        let alertController = UIAlertController(title: "Argh Matey!", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))
        return alertController
    }
    
}
