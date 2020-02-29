//
//  DetailNavigationControllerAnimator.swift
//  getlocation
//
//  Created by Oleg Komaristy on 10.02.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class DetailNavigationControllerAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	let operation: UINavigationController.Operation

	init(operation: UINavigationController.Operation) {
        self.operation = operation
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }

        if operation == .push {
            switch toVC is PlaceholderViewControllerType {
            case true:
                animatePushAsPop(from: fromVC, to: toVC, using: transitionContext)
            case false:
                animatePush(from: fromVC, to: toVC, using: transitionContext)
            }
        } else if operation == .pop {
            animatePop(from: fromVC, to: toVC, using: transitionContext)
        }
    }

    // MARK: - Push / Pop

    private func animatePush(from fromVC: UIViewController, to toVC: UIViewController, using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)

        let dx = containerView.frame.size.width
        toVC.view.frame = finalFrame.offsetBy(dx: dx, dy: 0.0)
        containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext), delay: 0,
			options: [ UIView.AnimationOptions.curveEaseOut ],
            animations: {
                toVC.view.frame = transitionContext.finalFrame(for: toVC)
                fromVC.view.frame = finalFrame.offsetBy(dx: dx / -2.5, dy: 0.0)
        },
            completion: { (_) in transitionContext.completeTransition(true) }
        )
    }

    private func animatePushAsPop(from fromVC: UIViewController, to toVC: UIViewController, using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)

        let dx = containerView.frame.size.width
        toVC.view.frame = finalFrame.offsetBy(dx: dx / -2.5, dy: 0.0)
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext), delay: 0,
			options: [ UIView.AnimationOptions.curveEaseOut ],
            animations: {
                toVC.view.frame = transitionContext.finalFrame(for: toVC)
                fromVC.view.frame = finalFrame.offsetBy(dx: dx, dy: 0.0)
        },
            completion: { (_) in transitionContext.completeTransition(true) }
        )
    }

    private func animatePop(from fromVC: UIViewController, to toVC: UIViewController, using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext), delay: 0,
			options: [ UIView.AnimationOptions.curveEaseOut ],
            animations: {
                fromVC.view.frame = containerView.bounds.offsetBy(dx: containerView.frame.width, dy: 0)
                toVC.view.frame = containerView.bounds
        },
            completion: { (_) in transitionContext.completeTransition(true) }
        )
    }

}
