//
//  TabBarCoordinator.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-02-15.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class TabBarCoordinator: BaseCoordinator, TabBarCoordinatorOutput {

	var finishFlow: (() -> Void)?
	var onShowTutorial: (() -> Void)?

	private let tabBarView: TabBarView
	private let coordinatorFactory: CoordinatorFactory

	init(tabBarView: TabBarView, coordinatorFactory: CoordinatorFactory ) {
		self.tabBarView = tabBarView
		self.coordinatorFactory = coordinatorFactory
	}

	#if DEBUG
	deinit {
		print("\(self) deinited.")
	}
	#endif
	
	override func start() {
		tabBarView.onItemDidLoad = runItemFlow()
		tabBarView.onItemFlowSelect = runItemFlow()

		tabBarView.onPostsFlowSelect = runPostsFlow()
		tabBarView.onScheduleFlowSelect = runScheduleFlow()

		tabBarView.onSettingsFlowSelect = runSettingsFlow()
	}

	private func runItemFlow() -> ((UINavigationController) -> Void) {
		return { [unowned self] navController in
			if navController.viewControllers.isEmpty {
				let itemCoordinator = self.coordinatorFactory.makeItemCoordinator(navController: navController)
				self.addDependency(itemCoordinator)
				itemCoordinator.start()
			}
		}
	}

	private func runSettingsFlow() -> ((UINavigationController) -> Void) {
		return { [unowned self] navController in
			if navController.viewControllers.isEmpty {

				let settingsCoordinator = self.coordinatorFactory.makeSettingsCoordinator(navController: navController)
				settingsCoordinator.finishFlow = { [weak self] in
					self?.finishFlow?()
				}

				settingsCoordinator.onShowTutorial = { [weak self] in
					self?.onShowTutorial?()
				}

				self.addDependency(settingsCoordinator)
				settingsCoordinator.start()
			}
		}
	}

	private func runPostsFlow() -> ((UINavigationController) -> Void) {
		return { [unowned self] navController in
			if navController.viewControllers.isEmpty {
				let postsCoordinator = self.coordinatorFactory.makePostsCoordinator(navController: navController)

				self.addDependency(postsCoordinator)
				postsCoordinator.start()
			}
		}
	}

	private func runScheduleFlow() -> ((UINavigationController) -> Void) {
		return { [unowned self] navController in
			if navController.viewControllers.isEmpty {

				let scheduledCoordinator = self.coordinatorFactory.makeScheduledPostsCoordinator(navController: navController)

				self.addDependency(scheduledCoordinator)
				scheduledCoordinator.start()
			}
		}
	}
}
