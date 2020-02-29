//
//  NewTrackerCoordinator.swift
//  getlocation
//
//  Created by Oleg Komaristy on 09.02.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit
import GeoTrackerCore

class NewTrackerCoordinator: Coordinator {
	var childCoordinators = [Coordinator]()
	weak var parentCoordinator: Coordinator?
	var navigationController: UINavigationController
	
	private var _navigationController: UINavigationController?
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
	
	func start() {
		let viewController = NewTrackerViewController.instantiate()
		viewController.coordinator = self
		let viewModel = TrackerRecorderViewModel()
		viewController.viewModel = viewModel
		
		_navigationController = UINavigationController()
		_navigationController?.viewControllers = [viewController]
		navigationController.present(_navigationController!, animated: true)
	}

	func startRecording(with viewModel: TrackerRecorderViewModel) {
		let viewController = StartTrackingViewController.instantiate()
		viewController.coordinator = self
		viewController.viewModel = viewModel
		
		// dismiss NewTrackerViewController and then present StartTrackingViewController
		navigationController.presentedViewController?
			.dismiss(
				animated: true,
				completion: { [weak self] in
					self?.navigationController.present(viewController, animated: true)
				}
			)
				
		LocationManager.shared.requestWhenInUseAuthorization()
	}
	
	func finish() {
		navigationController.presentedViewController?.dismiss(animated: true)
		navigationController.popToRootViewController(animated: true)
		parentCoordinator?.childCoordinatorDidFinish(self)
	}
}
