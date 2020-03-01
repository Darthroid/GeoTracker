//
//  SplitViewDelegate.swift
//  getlocation
//
//  Created by Oleg Komaristy on 09.02.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation

import UIKit

final class SplitViewDelegate: NSObject {

    let detailNavigationController: UINavigationController

    init(detailNavigationController: UINavigationController) {
        self.detailNavigationController = detailNavigationController
        super.init()
    }

    /// Changes the view controller displayed in the detail navigation controller.
    ///
    /// - Parameters:
    ///   - primaryContainer: The `PrimaryContainerType` containing the `.detailView` used to update the detail nav controller.
    ///   - animated: If `true`, animates the update.
    func updateSecondaryWithDetail(from primaryContainer: PrimaryContainerType, animated: Bool = false) {
        switch primaryContainer.detailView {
        case .collapsed(let detailViewController):
            detailNavigationController.setViewControllers([detailViewController], animated: animated)
        case .separated(let detailViewController):
            detailNavigationController.setViewControllers([detailViewController], animated: animated)
        case .placeholder:
            detailNavigationController.setViewControllers([primaryContainer.makePlaceholderViewController()],
                                                          animated: animated)
        }
    }

    /// Sets view of detail navigation controller to a placeholder view controller.
    ///
    /// - Parameter viewController: Placeholder view controller to use.
    func replaceDetail(withEmpty viewController: UIViewController & PlaceholderViewControllerType) {
        detailNavigationController.setViewControllers([viewController], animated: true)
    }

}

// MARK: - UITabBarControllerDelegate
extension SplitViewDelegate: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        /// Prevent selection of the same tab twice (which would reset its navigation controller)
        return tabBarController.selectedViewController === viewController ? false : true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard
            let splitViewController = tabBarController.splitViewController,
            let selectedNavController = viewController as? PrimaryContainerType else {
                fatalError("\(#function) FAILED : wrong view controller type")
        }
        /// If split view controller is collapsed, detail view will already be on `selectedNavController.viewControllers`;
        /// otherwise, we need to change the secondary view controller to the selected tab's detail view.
        if !splitViewController.isCollapsed {
            updateSecondaryWithDetail(from: selectedNavController)
        }
    }

}

// MARK: - UISplitViewControllerDelegate
extension SplitViewDelegate: UISplitViewControllerDelegate {

    // MARK: Collapsing the Interface

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard
            let tabBarController = splitViewController.viewControllers.first as? UITabBarController,
            let navigationControllers = tabBarController.viewControllers as? [PrimaryContainerType] else {
                fatalError("\(#function) FAILED : wrong view controller type")
        }

        navigationControllers.forEach { $0.collapseDetail() }
        return true /// Prevent UIKit from performing default collapse behavior
    }

    // MARK: Expanding the Interface

    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        guard
            let tabBarController = primaryViewController as? UITabBarController,
            let navigationControllers = tabBarController.viewControllers as? [PrimaryContainerType],
            let selectedNavController = tabBarController.selectedViewController as? PrimaryContainerType else {
                fatalError("\(#function) FAILED : wrong view controller type")
        }

        navigationControllers.forEach { $0.separateDetail() }

        /// There is no point in hiding the primary view controller with a placeholder detail view
        if case .placeholder = selectedNavController.detailView,
			splitViewController.preferredDisplayMode == .primaryHidden {
				splitViewController.preferredDisplayMode = .allVisible
        }
        updateSecondaryWithDetail(from: selectedNavController)
        return detailNavigationController
    }

    // MARK: Overriding the Presentation Behavior

    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        guard
            let tabBarController = splitViewController.viewControllers.first as? UITabBarController,
            let selectedNavController = tabBarController.selectedViewController as? UINavigationController
                & PrimaryContainerType else {
                    fatalError("\(#function) FAILED : wrong view controller type")
        }

        vc.navigationItem.leftItemsSupplementBackButton = true
        vc.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem

        if splitViewController.isCollapsed {
            selectedNavController.pushViewController(vc, animated: true)
            selectedNavController.detailView = .collapsed(vc)
        } else {
            switch selectedNavController.detailView {
            /// Animate only the initial presentation of the detail vc
            case .placeholder:
                detailNavigationController.setViewControllers([vc], animated: true)
            default:
                detailNavigationController.setViewControllers([vc], animated: false)
            }
            selectedNavController.detailView = .separated(vc)
        }
        return true /// Prevent UIKit from performing default behavior
    }

}
