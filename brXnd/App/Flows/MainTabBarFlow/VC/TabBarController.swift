//
//  TabBarController.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-02-15.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class TabBarController: UITabBarController, UITabBarControllerDelegate, TabBarView {

	var onItemDidLoad: ((UINavigationController) -> Void)?
	var onItemFlowSelect: ((UINavigationController) -> Void)?

	var onPostsFlowSelect: ((UINavigationController) -> Void)?
	var onScheduleFlowSelect: ((UINavigationController) -> Void)?

	var onSettingsFlowSelect: ((UINavigationController) -> Void)?

	override func viewDidLoad() {
		super.viewDidLoad()

		delegate = self

		if let controller = customizableViewControllers?.first as? UINavigationController {
			onItemDidLoad?(controller)
		}
		setupUI()
	}

	private func setupUI() {
		tabBar.tintColor = BRXNDColors.uglyPurple
		tabBar.barTintColor = UIColor.white
		tabBar.unselectedItemTintColor = UIColor.black.withAlphaComponent(0.7)
	}

	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

		//tab bar controllers as UINavigationControllers were set up in Main.storyboard
		guard let controller = viewControllers?[selectedIndex] as? UINavigationController else { return }
		switch selectedIndex {
		case 0:
			onItemFlowSelect?(controller)
		case 1:
			onPostsFlowSelect?(controller)
		case 2:
			onScheduleFlowSelect?(controller)
		case 3:
			onSettingsFlowSelect?(controller)
		default:
			fatalError("Can't start a non-existing flow.")
		}
	}
}
