//
//  DetailNavigationController.swift
//  getlocation
//
//  Created by Oleg Komaristy on 10.02.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class DetailNavigationController: UINavigationController {

    init() {
        super.init(nibName: nil, bundle: nil)
        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - UINavigationControllerDelegate
extension DetailNavigationController: UINavigationControllerDelegate {

	public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard operation == .push, toVC is PlaceholderViewController else {
            return nil
        }

        return DetailNavigationControllerAnimator(operation: operation)
    }

}
