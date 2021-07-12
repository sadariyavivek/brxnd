//
//  SettingsViewModel.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Action

protocol SettingsViewModelCoordinator: class {
	var onLogOut: (() -> Void)? {get set}
	var onShowTutorial: (() -> Void)? { get set }
	var onSocialMediaTap: (() -> Void)? { get set }
	var onTermsOfService: ((String) -> Void)? { get set }
	var onPrivacyPolicy: ((String) -> Void)? { get set }
}

protocol SettingsViewModelInput {
	var viewDidAppearTrigger: PublishSubject<Void> { get }

	var logOutAction: Action<Void, Void> { get }
	var showTutorialAction: Action<Void, Void> { get }
	var socialMediaAction: Action<Void, Void> { get }
	var termsOfServiceAction: Action<Void, Void> { get }
	var privacyPolicyAction: Action<Void, Void> { get }
}

protocol SettingsViewModelOutput {
	var userAccountDetails: Driver<UserResponse?> { get }
}

protocol SettingsViewModelType {
	var input: SettingsViewModelInput { get }
	var output: SettingsViewModelOutput { get }
	var coordinator: SettingsViewModelCoordinator { get }
}

final class SettingsViewModel: SettingsViewModelType,
	SettingsViewModelInput,
	SettingsViewModelOutput,
SettingsViewModelCoordinator {

	// MARK: - Inputs
	var viewDidAppearTrigger = PublishSubject<Void>()

	// MARK: - Actions
	lazy var logOutAction: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.removeCurrentUser()
			self.onLogOut?()
			return Observable.just(())
		}
	}()

	lazy var showTutorialAction: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.onShowTutorial?()
			return Observable.just(())
		}
	}()

	lazy var socialMediaAction: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.onSocialMediaTap?()
			return Observable.just(())
		}
	}()

	lazy var termsOfServiceAction: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.onTermsOfService?(Current.termsConditions)
			return Observable.just(())
		}
	}()

	lazy var privacyPolicyAction: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.onPrivacyPolicy?(Current.privacyPolicy)
			return Observable.just(())
		}
	}()

	// MARK: - Outputs
	var userAccountDetails: Driver<UserResponse?>

	// MARK: - Coordinator
	var onLogOut: (() -> Void)?
	var onShowTutorial: (() -> Void)?
	var onSocialMediaTap: (() -> Void)?
	var onTermsOfService: ((String) -> Void)?
	var onPrivacyPolicy: ((String) -> Void)?

	var input: SettingsViewModelInput { return self }
	var output: SettingsViewModelOutput { return self }
	var coordinator: SettingsViewModelCoordinator { return self }

	//	private let userAPI: UserAPI
	//	private let registrationAPI: UserRegistrationAPI
	private let facebookLoginManager: FacebookLoginManager
	private let appSettings: AppSettings

	private let disposeBag: DisposeBag = DisposeBag()

	init(userAPI: UserAPI = UserAPI(),
		 registrationAPI: UserRegistrationAPI = UserRegistrationAPI(),
		 facebookLoginManager: FacebookLoginManager = FacebookLoginManager.shared,
		 appSettings: AppSettings = AppSettings.shared) {

		//		self.userAPI = userAPI
		self.facebookLoginManager = facebookLoginManager
		self.appSettings = appSettings

		let response = viewDidAppearTrigger
			.flatMapLatest {  _ in
				return userAPI
					.rx
					.getUserInfo()
		}

		//limitation of the back-end, the facebook data has to be uploaded manually...
		if Current.getLoggedInState() == SocialMediaState.loggedInFacebook
			&& !appSettings.wasFacebookDataUploaded() {

			let getUserDataFromGraphAPI = facebookLoginManager
				.rx
				.profileDataRequest()
				.observeOn(MainScheduler.instance)
				.map(extractSuccess)
				.compactMap { $0 }

			let uploadFacebookDataToBackEnd = getUserDataFromGraphAPI
				.flatMapLatest { data -> Observable<Result<BRXNDFBAccUploadResponse, Error>> in
					if let name: String = data["name"] as? String,
						let email: String = data["email"] as? String,
						let token: String = data["token"] as? String {

						return registrationAPI
							.rx
							.facebookUserDataUpload(email: email, name: name, token: token)
							.observeOn(MainScheduler.instance)
						
					} else {
						// error can be ignored
						return Observable.just(.failure(NSError()))
					}
			}

			uploadFacebookDataToBackEnd
//				.debug("⛱ Facebook data upload:", trimOutput: false)
				.take(1)
				.subscribe(onNext: { _ in appSettings.setFacebookDataUploaded(true)})
				.disposed(by: disposeBag)
		}

		userAccountDetails = response
			.map(extractSuccess)
			.asDriver(onErrorJustReturn: nil)
	}

	private func removeCurrentUser() {
		AuthHelper.removeCurrentUser()
		if Current.getLoggedInState() == SocialMediaState.loggedInFacebook {
			facebookLoginManager.logOut()
			appSettings.setFacebookDataUploaded(false)
		}
		Current.user = nil
	}

}
