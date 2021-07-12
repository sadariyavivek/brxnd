//
//  ApplicationCoordinator.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-01-29.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

#if DEBUG
private var isAuthorized: Bool = true
private var onboardingWasShown: Bool = true
#else
private var isAuthorized: Bool = Current.user != nil
private var onboardingWasShown: Bool {
	get {return OnboardingHelper.wasOnboardingShown()}
	set {OnboardingHelper.setOnboardingStatus(newValue)}
}
#endif

private enum LaunchInstructor {
	case auth, onboarding, main
	
	static func configure(tutorialWasShown: Bool = onboardingWasShown,
						  isAuthorized: Bool = isAuthorized) -> LaunchInstructor {
		switch (tutorialWasShown, isAuthorized) {
        
		case (true, false), (false, false): return .auth
		case (false, true): return .onboarding
		case (true, true): return .main
		}
	}
}

final class ApplicationCoordinator: BaseCoordinator {
	
	private let coordinatorFactory: CoordinatorFactory
	private let router: Router
	
	private var instructor: LaunchInstructor {
		return LaunchInstructor.configure()
	}
	
	init(coordinatorFactory: CoordinatorFactory, router: Router) {
		self.coordinatorFactory = coordinatorFactory
		self.router = router
	}
	
	override func start() {
		switch instructor {
		case .auth: runLoginFlow()
		case .onboarding: runOnboardingFlow()
		case .main: runMainFlow()
		}
	}
	
	private func runLoginFlow() {
		let coordinator = coordinatorFactory.makeAuthCoordinator(router: router)
		coordinator.finishFlow = { [unowned self, weak coordinator] in
			isAuthorized = true
			self.start()
			self.removeDependency(coordinator)
		}
		addDependency(coordinator)
		coordinator.start()
	}
	
	private func runOnboardingFlow() {
		let coordinator = coordinatorFactory.makeOnboardingCoordinator(router: router)
		coordinator.finishFlow = { [unowned self, weak coordinator] in
			onboardingWasShown = true
			self.start()
			self.removeDependency(coordinator)
		}
		addDependency(coordinator)
		coordinator.start()
	}
	
	private func runMainFlow() {
		let (coordinator, module) = coordinatorFactory.makeTabBarCoordinator()
		
		coordinator.finishFlow = { [unowned self] in
			isAuthorized = false
			self.logOutCleanup()
			self.start()
		}
		
		coordinator.onShowTutorial = { [unowned self] in
			self.runOnboardingFlow()
		}
		
		addDependency(coordinator)
		router.setRootModule(module, hideBar: true)
		coordinator.start()
	}
	
	private func logOutCleanup() {
		///coordinator cleanup
		self.childCoordinator.forEach { coordinator in
			self.removeDependency(coordinator)
		}
		///navigation cleanup
		guard let navigationController =
			UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
			else { fatalError("Can't get current nav controller") }
		navigationController.viewControllers.removeAll()
	}
}
