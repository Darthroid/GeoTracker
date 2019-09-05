//
//  PrimarySplitViewController.swift
//  gpstracky
//
//  Created by Oleg Komaristy on 04.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
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
