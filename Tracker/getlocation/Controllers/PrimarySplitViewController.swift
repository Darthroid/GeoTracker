//
//  PrimarySplitViewController.swift
//  getlocation
//
//  Created by Олег Комаристый on 12.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class PrimarySplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
}
