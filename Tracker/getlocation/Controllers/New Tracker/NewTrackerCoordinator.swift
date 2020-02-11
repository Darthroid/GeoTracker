//
//  NewTrackerCoordinator.swift
//  getlocation
//
//  Created by Oleg Komaristy on 09.02.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class NewTrackerCoordinator: Coordinator {
	var childCoordinators = [Coordinator]()
	var navigationController: UINavigationController
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
	
	func start() {
		let viewController = NewTrackerViewController.instantiate()
		viewController.coordinator = self
        navigationController.viewControllers = [viewController]

		let viewModel = TrackerRecorderViewModel()
		viewController.viewModel = viewModel
	}
	
}
