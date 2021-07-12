//
//  CoordinatorFactory.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-01-29.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol CoordinatorFactory {

	/*
	coordinators should be created here.
	*/

	func makeOnboardingCoordinator(router: Router) -> Coordinator & OnboardingCoordinatorOutput
	func makeAuthCoordinator(router: Router) -> Coordinator & AuthCoordinatorOutput
	func makeTabBarCoordinator() -> (configurator: Coordinator & TabBarCoordinatorOutput, toPresent: UIPresentable?)

	func makeItemCoordinator() -> Coordinator
	func makeItemCoordinator(navController: UINavigationController?) -> Coordinator

//	func makeItemCreationCoordinatorBox() ->
//		(configurator: Coordinator & CreateItemCoordinatorOutput,
//		toPresent: UIPresentable?)
//
//	func makeItemCreationCoordinatorBox(navController: UINavigationController?) ->
//		(configurator: Coordinator & CreateItemCoordinatorOutput,
//		toPresent: UIPresentable?)

	func makeSettingsCoordinator() -> Coordinator & SettingsCoordinatorOutput
	func makeSettingsCoordinator(navController: UINavigationController?) -> Coordinator & SettingsCoordinatorOutput
	
	func makeCameraCoordinatorBox() -> (configurator: Coordinator & CameraCoordinatorOutput, toPresent: UIPresentable?)
	
	func makeLibraryItemEditorCoordinatorBox(with dependency: MediaItem) ->
		(configurator: Coordinator & EditFlowCoordinatorOutput,
		toPresent: UIPresentable?)

	func makeLibraryItemEditorCoordinatorBox(with dependency: MediaItem, navController: UINavigationController?) ->
		(configurator: Coordinator & EditFlowCoordinatorOutput,
		toPresent: UIPresentable?)

	func makePostsCoordinator() -> Coordinator
	func makePostsCoordinator(navController: UINavigationController?) -> Coordinator

	func makeScheduledPostsCoordinator() -> Coordinator 
	func makeScheduledPostsCoordinator(navController: UINavigationController?) -> Coordinator

	func makePostingCoordinatorBox(with dependency: MediaItem) ->
		(configurator: Coordinator & PostingFlowCoordinatorOutput,
		toPresent: UIPresentable?)

	func makePostingCoordinatorBox(with dependency: MediaItem, navController: UINavigationController?) ->
		(configurator: Coordinator & PostingFlowCoordinatorOutput,
		toPresent: UIPresentable?)
}
