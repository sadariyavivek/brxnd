//
//  LoginViewModel.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-19.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class LoginViewModel {

	#if DEBUG
	deinit {
		print("LoginVM deinit \(String(describing: self))")
	}
	#endif

	// coordinator output
	var onLoginTap: (() -> Void)?
	var onSignUpTap: (() -> Void)?

	let loginAPI: UserLoginAPI
	let facebookLoginManager: FacebookLoginManager

	let disposeBag = DisposeBag()

	init (loginAPI: UserLoginAPI, facebookLoginManager: FacebookLoginManager = FacebookLoginManager.shared) {
		self.loginAPI = loginAPI
		self.facebookLoginManager = facebookLoginManager
	}

    
	func transform(input: (
		email: Driver<String>,
		password: Driver<String>,
		signUpFacebookTap: Observable<Void>,
		signUpEmailTap: Observable<Void>,
		signIn: Observable<Void>))
		->
        
		(validatedEmail: Driver<ValidationResult>,
		validatedPassword: Driver<ValidationResult>,
		signInEnabled: Driver<Bool>,
		signedIn: Driver<Bool>,
		signingIn: Driver<Bool>) {

			let validationService 	= ValidationService()

			let validatedEmail = input.email
				.flatMapLatest { username in
					return validationService.validateEmail(username)
						.asDriver(onErrorJustReturn: .failed(message: "Failed to validate"))
			}

			let validatedPassword = input.password
				.map { password in
					return validationService.validatedPassword(password)
			}

			let pair = Driver.combineLatest(input.email, input.password) {(email: $0, password: $1)}

			let signingInActivityIndicator = RxActivityIndicator()
			let signingIn = signingInActivityIndicator.asDriver()

			let signedInCoordinatorOutput = input.signIn.withLatestFrom(pair)
				.flatMapLatest { [unowned self] pair in
					return self.loginAPI.rx.signIn(email: pair.email, password: pair.password)
						.observeOn(MainScheduler.instance)
						.trackActivity(signingInActivityIndicator)
						.catchErrorJustReturn(.failure(NSError()))
			}.share(replay: 1, scope: .forever)

			let signedInVcOutput = signedInCoordinatorOutput
				.map { result in
					switch result {
					case .success:
						return true
					case .failure:
						return false
					}
			}.asDriver(onErrorJustReturn: false)

			/*coordinator output*/
			/*side effects*/
			signedInCoordinatorOutput
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: { [weak self] result in
					switch result {
					case .success(let user):
						Current.user = user
						self?.onLoginTap?()
					default: return
					}
				}).disposed(by: disposeBag)

			let facebookTap = input.signUpFacebookTap

			facebookTap
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: { [weak self] in
					self?.facebookLoginManager.logIn(completion: { result in
						switch result {
						case .success:
							DispatchQueue.main.async {
								self?.onLoginTap?()
							}
						case .failure(let error):
							#if DEBUG
							print("Facebook log-in failed with error: \(error)")
							#endif
							return
						}
					})
				}).disposed(by: disposeBag)

			let emailTap = input.signUpEmailTap

			emailTap
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: { [weak self] in
					self?.onSignUpTap?()
				}).disposed(by: disposeBag)
			/*side effects*/
			/*coordinator output*/

			let signInEnabled = Driver.combineLatest(
				validatedEmail,
				validatedPassword,
				signingIn
			) { username, password, signingIn in
				username.isValid &&
					password.isValid &&
					!signingIn
			}

			return (
				validatedEmail: validatedEmail,
				validatedPassword: validatedPassword,
				signInEnabled: signInEnabled,
				signedIn: signedInVcOutput,
				signingIn: signingIn
			)
	}
}
