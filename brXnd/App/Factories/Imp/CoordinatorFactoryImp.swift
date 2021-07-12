//
//  CoordinatorFactoryImp.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-01-30.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class CoordinatorFactoryImp: CoordinatorFactory {

	//onboarding
	func makeOnboardingCoordinator(router: Router) -> Coordinator & OnboardingCoordinatorOutput {
		return OnboardingCoordinator(with: ModuleFactoryImp(), router: router)
	}
	
	//auth
	func makeAuthCoordinator(router: Router) -> AuthCoordinatorOutput & Coordinator {
		return AuthCoordinator(with: ModuleFactoryImp(), router: router)
	}
	
	//main tabBar
	func makeTabBarCoordinator() -> (configurator: Coordinator & TabBarCoordinatorOutput, toPresent: UIPresentable?) {
		let controller = TabBarController.controllerFromStoryboard(.main)
		let coordinator = TabBarCoordinator(tabBarView: controller,
											coordinatorFactory: CoordinatorFactoryImp())
		return (coordinator, controller)
	}
	
	//items
	func makeItemCoordinator() -> Coordinator {
		return makeItemCoordinator(navController: nil)
	}
	
	private func router(_ navController: UINavigationController?) -> Router {
		return RouterImp(rootController: navigationController(navController))
	}
	//always returns the main nav controller, if no one else available.
	private func navigationController(_ navController: UINavigationController?) -> UINavigationController {
		if let navController = navController { return navController } else { return UINavigationController.controllerFromStoryboard(.main)}
	}
	
	func makeItemCoordinator(navController: UINavigationController?) -> Coordinator {
		let coordinator = StudioCoordinator(router: router(navController),
											factory: ModuleFactoryImp(),
											coordinatorFactory: CoordinatorFactoryImp()
		)
		return coordinator
	}
	
	///create item
	//	func makeItemCreationCoordinatorBox(navController: UINavigationController?) ->
	//		(configurator: Coordinator & CreateItemCoordinatorOutput, toPresent: UIPresentable?) {
	//			let router = self.router(navController)
	//			let coordinator = CreateItemCoordinator(factory: ModuleFactoryImp(),
	//													router: router)
	//			return (coordinator, router)
	//	}
	//
	//	func makeItemCreationCoordinatorBox() ->
	//		(configurator: Coordinator & CreateItemCoordinatorOutput, toPresent: UIPresentable?) {
	//			return makeItemCreationCoordinatorBox(navController: navigationController(nil))
	//	}

	//create settings
	func makeSettingsCoordinator() -> Coordinator & SettingsCoordinatorOutput {
		return makeSettingsCoordinator(navController: nil)
	}
	
	func makeSettingsCoordinator(navController: UINavigationController? = nil) -> Coordinator & SettingsCoordinatorOutput {
		let coordinator = SettingsCoordinator(router: router(navController),
											  factory: ModuleFactoryImp())
		return coordinator
	}
	
	//camera
	func makeCameraCoordinatorBox() -> (configurator: Coordinator & CameraCoordinatorOutput, toPresent: UIPresentable?) {
		return makeCameraCoordinatorBox(navController: nil)
	}
	
	func makeCameraCoordinatorBox(navController: UINavigationController?) -> (configurator: Coordinator & CameraCoordinatorOutput, toPresent: UIPresentable?) {
		let router = self.router(navController)
		let coordinator = CameraCoordinator(router: router,
											factory: ModuleFactoryImp())
		return (coordinator, router)
	}

	//editor
	func makeLibraryItemEditorCoordinatorBox(with dependency: MediaItem) ->
		(configurator: Coordinator & EditFlowCoordinatorOutput, toPresent: UIPresentable?) {
			return makeLibraryItemEditorCoordinatorBox(with: dependency, navController: nil)
	}

	func makeLibraryItemEditorCoordinatorBox(with dependency: MediaItem, navController: UINavigationController?) ->
		(configurator: Coordinator & EditFlowCoordinatorOutput, toPresent: UIPresentable?) {
			let router = self.router(navController)
			let coordinator = EditFlowCoordinator(router: router,
												  libraryItem: dependency,
												  factory: ModuleFactoryImp())
			return (coordinator, router)
	}

	//posts
	func makePostsCoordinator() -> Coordinator {
		return makePostsCoordinator(navController: nil)
	}

	func makePostsCoordinator(navController: UINavigationController?) -> Coordinator {
		let coordinator = PostsCoordinator(factory: ModuleFactoryImp(),
										   router: router(navController))
		return coordinator
	}

	//scheduled
	func makeScheduledPostsCoordinator() -> Coordinator {
		return makeScheduledPostsCoordinator(navController: nil)
	}

	func makeScheduledPostsCoordinator(navController: UINavigationController?) -> Coordinator {
		let coordinator = ScheduleCoordinator(factory: ModuleFactoryImp(),
											  router: router(navController))
		return coordinator
	}

	//posting

	func makePostingCoordinatorBox(with dependency: MediaItem, navController: UINavigationController?)
		-> (configurator: Coordinator & PostingFlowCoordinatorOutput, toPresent: UIPresentable?) {
			let router = self.router(navController)
			let coordinator = PostingCoordinator(factory: ModuleFactoryImp(),
												 router: router,
												 mediaItem: dependency)
			return (coordinator, router)
	}

	func makePostingCoordinatorBox(with dependency: MediaItem)
		-> (configurator: Coordinator & PostingFlowCoordinatorOutput, toPresent: UIPresentable?) {
		return makePostingCoordinatorBox(with: dependency, navController: nil)
	}

}
