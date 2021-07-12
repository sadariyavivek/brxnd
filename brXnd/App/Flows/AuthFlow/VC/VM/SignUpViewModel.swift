//
//  SignUpViewModel.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-22.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

/*
Inspired from RxExamples
https://github.com/ReactiveX/RxSwift
*/

final class SignUpViewModel {

	#if DEBUG
	deinit {
		print("SignUpVM deinit \(String(describing: self))")
	}
	#endif
	
	//coordinator output
	var onSignUpComplete: (() -> Void)?
	var onTermsTap: (() -> Void)?

	let disposeBag = DisposeBag()

	init () {}

	func transform(input: (
		email: Driver<String>,
		password: Driver<String>,
		repeatedPassword: Driver<String>,
		loginTap: Observable<Void>,
		termsTap: Observable<Void>))

		->

		(validatedEmail: Driver<ValidationResult>,
		validatedPassword: Driver<ValidationResult>,
		validatedPasswordRepeated: Driver<ValidationResult>,
		signupEnabled: Driver<Bool>,
		signedIn: Driver<Bool>,
		signingIn: Driver<Bool>) {

			let registrationAPI 	= UserRegistrationAPI()
			let loginAPI 			= UserLoginAPI()
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

			let validatedPasswordRepeated = Driver.combineLatest(input.password, input.repeatedPassword,
																 resultSelector: validationService.validateRepeatedPassword)

			//activity indicator
			let signingInActivityIndicator = RxActivityIndicator()
			let signingIn = signingInActivityIndicator.asDriver()

			let pair = Driver.combineLatest(input.email, input.password) {(email: $0, password: $1)}

			/*
			limitation of the current api. send another req, to get the user.
			it sends the registration request,and then tries to login with the same creds sent
			*/
			let signedInCoordinatorOutput = input.loginTap.withLatestFrom(pair)
				.flatMapLatest { pair in
					return registrationAPI.rx.signUp(pair.email, pair.email, pair.password)
						.observeOn(MainScheduler.instance)
						.catchErrorJustReturn(false)
						.trackActivity(signingInActivityIndicator)
			}
			.withLatestFrom(pair)
			.flatMapLatest { pair in
				return loginAPI.rx.signIn(email: pair.email, password: pair.password)
					.observeOn(MainScheduler.instance)
					.trackActivity(signingInActivityIndicator)
					.catchErrorJustReturn(.failure(NSError()))
			}.share(replay: 1, scope: .forever)

			//convert the result from signed in to bool, for vc observation
			let signedInVcOutput = signedInCoordinatorOutput
				.map { result in
					switch result {
					case .success:
						return true
					case .failure:
						return false
					}
			}
			.asDriver(onErrorJustReturn: false)

			let signupEnabled = Driver.combineLatest(
				validatedEmail,
				validatedPassword,
				validatedPasswordRepeated,
				signingIn
			) { username, password, repeatPassword, signingIn in
				username.isValid &&
					password.isValid &&
					repeatPassword.isValid &&
					!signingIn
			}.distinctUntilChanged()

			/* coordinator output */
			/* side effects */
			//shouldn't be here. Will use it like this until converting coordinators with RX.
			let termsConditions = input.termsTap

			termsConditions
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: { [weak self] _ in
					self?.onTermsTap?()
				}).disposed(by: disposeBag)

			signedInCoordinatorOutput
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: { [weak self] result in
					switch result {
					case .success(let user):
						Current.user = user
						self?.onSignUpComplete?()
					default: return
					}
				}).disposed(by: disposeBag)
			/* side effects */
			/* coordinator output */

			return (
				validatedEmail: validatedEmail,
				validatedPassword: validatedPassword,
				validatedPasswordRepeated: validatedPasswordRepeated,
				signupEnabled: signupEnabled,
				signedIn: signedInVcOutput,
				signingIn: signingIn
			)
	}
}
