//
//  PlaceholderViewController.swift
//  getlocation
//
//  Created by Oleg Komaristy on 10.02.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class PlaceholderViewController: UIViewController, PlaceholderViewControllerType {
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let displayModeButtonItem = splitViewController?.displayModeButtonItem {
            navigationItem.leftBarButtonItem = displayModeButtonItem
        }
    }

	// MARK: - View Methods

	func setupView() {
		if #available(iOS 13.0, *) {
			view.backgroundColor = UIColor.groupTableViewBackground
		} else {
			view.backgroundColor = UIColor.white
		}
		navigationItem.leftItemsSupplementBackButton = true
	}
}
