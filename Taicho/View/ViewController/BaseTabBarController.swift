//
//  BaseTabBarController.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/26/22.
//

import Foundation
import UIKit

class BaseTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let logActivityVC = UINavigationController(rootViewController: LogActivityViewController())
        let logListVC = UINavigationController(rootViewController: LogEntryListViewController())
        viewControllers = [
            logActivityVC,
            logListVC
        ]
        selectedIndex = 0

        let logActivityTab = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        let logListTab = UITabBarItem(tabBarSystemItem: .history, tag: 0)
        logActivityVC.tabBarItem = logActivityTab
        logListVC.tabBarItem = logListTab
    }

}
