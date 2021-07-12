//
//  FadeAnimationController.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-05-03.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

class FadeAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

	private let wasViewPresented: Bool
	private let animationDuration: Double

	init(isPresenting: Bool, animationDuration: Double = 1) {
		self.wasViewPresented = isPresenting
		self.animationDuration = animationDuration
	}

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return TimeInterval(animationDuration)
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard 	let fromView = transitionContext.view(forKey: .from),
				let toView = transitionContext.view(forKey: .to) else { return }

		let container = transitionContext.containerView
		if wasViewPresented {
			container.addSubview(toView)
			toView.alpha = 0.0
		} else {
			container.insertSubview(toView, belowSubview: fromView)
		}

		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { [weak self] in
			guard let strongSelf = self else { return }
			if strongSelf.wasViewPresented {
				toView.alpha = 1.0
			} else {
				fromView.alpha = 0.0
			}
		}) { _ in
			let success = !transitionContext.transitionWasCancelled
			if !success {
				toView.removeFromSuperview()
			}
			transitionContext.completeTransition(success)
		}
	}
}
