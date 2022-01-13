//
//  CustomNavigationController.swift
//  CustomTransitionDemo
//
//  Created by Ludvig Eriksson on 2018-01-22.
//  Copyright © 2018 Ludvig Eriksson. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {

    private var interactionController: UIPercentDrivenInteractiveTransition?
//    private var edgeSwipeGestureRecognizer: UIScreenEdgePanGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

//        edgeSwipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        edgeSwipeGestureRecognizer!.edges = .left
//        view.addGestureRecognizer(edgeSwipeGestureRecognizer!)
    }

//    @objc func handleSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
//        let percent = gestureRecognizer.translation(in: gestureRecognizer.view!).x / gestureRecognizer.view!.bounds.size.width
//
//        if gestureRecognizer.state == .began {
//            interactionController = UIPercentDrivenInteractiveTransition()
//            popViewController(animated: true)
//        } else if gestureRecognizer.state == .changed {
//            interactionController?.update(percent)
//        } else if gestureRecognizer.state == .ended {
//            if percent > 0.5 && gestureRecognizer.state != .cancelled {
//                interactionController?.finish()
//            } else {
//                interactionController?.cancel()
//            }
//            interactionController = nil
//        }
//    }
}

extension CustomNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return FadeAnimationController(presenting: true)
        } else {
            return FadeAnimationController(presenting: false)
        }
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}
