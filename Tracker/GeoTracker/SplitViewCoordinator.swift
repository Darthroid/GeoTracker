//
//  SplitViewCoordinator.swift
//  getlocation
//
//  Created by Oleg Komaristy on 09.02.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class SplitViewCoordinator: Coordinator {

	enum SectionTab: Int {
		case newTracker = 0
		case trackersList
		case settings

		var title: String {
			switch self {
//			case .newTracker: return "New tracker"
//			case .trackersList: return "Trackers list"
//			case .settings: return "Settings"
			default: return ""
			}
		}

		var image: UIImage {
			switch self {
			case .newTracker: return #imageLiteral(resourceName: "marker")
			case .trackersList: return #imageLiteral(resourceName: "list")
			case .settings: fallthrough
			@unknown default: return UIImage()
			}
		}
	}

	var childCoordinators = [Coordinator]()

	var window: UIWindow
// swiftlint:disable weak_delegate
	private let viewDelegate: SplitViewDelegate
// swiftlint:enable weak_delegate
	init(window: UIWindow) {
		self.window = window

		let detailNavigationController = DetailNavigationController()
		self.viewDelegate = SplitViewDelegate(detailNavigationController: detailNavigationController)
	}

	func start() {
		let tabBarController = UITabBarController()
		let tabs: [SectionTab] = [/*.newTracker,*/ .trackersList]

		self.configureTabBarController(tabBarController, with: tabs)

        if let initialPrimaryView = tabBarController.selectedViewController as? PrimaryContainerType {
            viewDelegate.updateSecondaryWithDetail(from: initialPrimaryView)
        }

		let splitViewController = UISplitViewController()
        splitViewController.delegate = viewDelegate
        splitViewController.viewControllers = [tabBarController, viewDelegate.detailNavigationController]
        splitViewController.preferredDisplayMode = .allVisible

		if #available(iOS 13.0, *) {
			splitViewController.primaryBackgroundStyle = .sidebar
		}

        window.rootViewController = splitViewController
        window.makeKeyAndVisible()
	}

	private func configureTabBarController(_ tabBarController: UITabBarController, with tabs: [SectionTab]) {
        let navControllers = tabs
            .map { tab -> UINavigationController in
                let navController = NavigationController(withPopDetailCompletion: viewDelegate.replaceDetail)
                navController.tabBarItem = UITabBarItem(title: tab.title, image: tab.image, selectedImage: nil)
				return navController
            }

        tabBarController.viewControllers = navControllers
		tabBarController.selectedIndex = SectionTab.trackersList.rawValue
        tabBarController.delegate = viewDelegate

		let coordinatorsSource = zip(tabs, navControllers)

		for (tab, navController) in coordinatorsSource {
			switch tab {
			case .newTracker:
				let coordinator = NewTrackerCoordinator(navigationController: navController)
				childCoordinators.append(coordinator)
				coordinator.start()
			case .trackersList:
				let coordinator = TrackerListCoordinator(navigationController: navController)
				childCoordinators.append(coordinator)
				coordinator.start()
			case .settings: fallthrough
			@unknown default:
				assertionFailure("not implemented")
			}
		}
	}

}
