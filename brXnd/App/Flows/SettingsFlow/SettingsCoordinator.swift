//
//  SettingsCoordinator.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-02-18.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class SettingsCoordinator: BaseCoordinator, SettingsCoordinatorOutput {

	var finishFlow: (() -> Void)?
	var onShowTutorial: (() -> Void)?

	private let factory: SettingsModuleFactory
	private let router: Router

	init(router: Router, factory: SettingsModuleFactory) {
		self.router = router
		self.factory = factory
	}

	#if DEBUG
	deinit {
		print("\(self) deinited.")
	}
	#endif

	override func start() {
		showSettings()
	}

	private func showSettings() {
		let (settingsVC, settingsVM) = factory.makeSettingsModule()
		settingsVM.coordinator.onLogOut = { [weak self] in
			self?.finishFlow?()
		}
		settingsVM.coordinator.onShowTutorial = { [weak self] in
			self?.onShowTutorial?()
		}
		settingsVM.coordinator.onPrivacyPolicy = { [weak self] policy in
			self?.showTerms(terms: policy)
		}
		settingsVM.coordinator.onTermsOfService = { [weak self] terms in
			self?.showTerms(terms: terms)
		}
		settingsVM.coordinator.onSocialMediaTap = { [weak self] in
			self?.showSocialMediaSettings()
		}
		router.setRootModule(settingsVC)
	}
	private func showTerms(terms: String) {
		let termsVC = factory.makeSettingsTerms(with: terms)
		router.push(termsVC, animated: true)
	}
	private func showSocialMediaSettings() {
		let socialVC = factory.makeSocialMediaModule()
		router.push(socialVC, animated: true)
	}
}
