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

        guard let activityImage = UIImage(named: "star-icon"), let listImage = UIImage(named: "search-icon") else {
            Log.assert("Failed to initialize images!")
            return
        }
        let logActivityTab = UITabBarItem(title: "Log", image: activityImage, tag: 0)
        let logListTab = UITabBarItem(title: "History", image: listImage, tag: 1)
        logActivityVC.tabBarItem = logActivityTab
        logListVC.tabBarItem = logListTab
    }

}
