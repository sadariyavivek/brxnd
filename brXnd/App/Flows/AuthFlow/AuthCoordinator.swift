//
//  AuthCoordinator.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-02-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class AuthCoordinator: BaseCoordinator, AuthCoordinatorOutput {

	var finishFlow: (() -> Void)?

	private let factory: AuthModuleFactory
	private let router: Router

	init(with factory: AuthModuleFactory, router: Router) {
		self.factory = factory
		self.router = router
	}
	#if DEBUG
	deinit {
		print("\(self) deinited.")
	}
	#endif
	override func start() {
		showLogin()
	}

	private func showLogin() {
		let (loginVC, loginVM) = factory.makeLoginModule()
		
		loginVM.onLoginTap = { [weak self] in
			self?.finishFlow?()
		}
		loginVM.onSignUpTap = { [weak self] in
			self?.showSignUp()
		}
		router.push(loginVC)
	}
	private func showSignUp() {
		let (signUpVC, signUpVM) = factory.makeSignUpModule()
		
		signUpVM.onSignUpComplete = { [weak self] in
			self?.finishFlow?()
		}
		signUpVM.onTermsTap = { [weak self] in
			self?.showTerms()
		}
		router.push(signUpVC)
	}

	private func showTerms() {
		let termsOutput = factory.makeTermsModule()
		termsOutput.onTermsSwitchTap = { [weak self] in
			self?.showSignUp()
		}
		router.push(termsOutput)
	}
}
