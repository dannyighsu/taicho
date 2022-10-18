//
//  LogActivityViewController.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/16/22.
//

import Foundation
import UIKit

/**
 The base view controller that allows you to log new activities.
 */
class LogActivityViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.pushViewController(LogEntryListViewController(), animated: false)
    }
    
}
