//
//  CustomNavBar.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-04-08.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class CustomNavigationController: UINavigationController {

	override func viewDidLoad() {
		super.viewDidLoad()
		delegate = self
		setupUI()
	}

	private func setupUI () {
		navigationItem.rightBarButtonItem?.tintColor = .black
		navigationItem.leftBarButtonItem?.tintColor = .black
		navigationController?.navigationBar.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.black,
			NSAttributedString.Key.font: UIFont(name: "SourceSansPro-SemiBold", size: 10.2)!
		]
		view.backgroundColor = BRXNDColors.veryLightBlue
	}

	//disable animations
//	override func popViewController(animated: Bool) -> UIViewController? {
//		return super.popViewController(animated: false)
//	}
//	override func popToRootViewController(animated: Bool) -> [UIViewController]? {
//		return super.popToRootViewController(animated: false)
//	}
}

extension CustomNavigationController: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) ->
		UIViewControllerAnimatedTransitioning? {

			//custom transition
			switch operation {
			case .push:
				if toVC is PhotoEditorView || toVC is VideoEditorView {
					return FadeAnimationController(isPresenting: true, animationDuration: 0.5)
				}
			case .pop:
				if toVC is EditorPreviewViewController {
					return FadeAnimationController(isPresenting: false, animationDuration: 0.5)
				}
			default:
				break
			}
			return nil
	}
}
