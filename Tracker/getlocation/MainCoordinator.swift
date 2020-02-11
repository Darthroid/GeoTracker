//
//  MainCoordinator.swift
//  getlocation
//
//  Created by Oleg Komaristy on 09.02.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
	var childCoordinators = [Coordinator]()
	var window: UIWindow

	init(window: UIWindow) {
		self.window = window
	}
	
	func start() {
		self.showSplitView()
	}
	
	private func showSplitView() {
		let splitViewCoordinator = SplitViewCoordinator(window: self.window)
		splitViewCoordinator.start()
	}
}
