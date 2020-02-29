//
//  Coordinator.swift
//  getlocation
//
//  Created by Oleg Komaristy on 09.02.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator: class {
	var childCoordinators: [Coordinator] { get set }
	func start()
	func childCoordinatorDidFinish(_ child: Coordinator)
}

extension Coordinator {
	func childCoordinatorDidFinish(_ child: Coordinator) {
		for (index, coordinator) in childCoordinators.enumerated() where coordinator === child {
			childCoordinators.remove(at: index)
			break
		}
	}
}
