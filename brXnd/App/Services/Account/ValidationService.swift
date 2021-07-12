//
//  ValidationService.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-03-19.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

enum ValidationResult {
	case ok(message: String)
	case empty
	case validating
	case failed(message: String)
}

extension ValidationResult {
	var isValid: Bool {
		switch self {
		case .ok:
			return true
		default:
			return false
		}
	}
}

protocol ValidationServiceProtocol {
	func validateEmail(_ email: String) -> Observable<ValidationResult>
	func validatedPassword(_ password: String) -> ValidationResult
	func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult
}

struct ValidationService: ValidationServiceProtocol {

	private let minPasswordCount = 6

	func validateEmail(_ email: String) -> Observable<ValidationResult> {
		if email.isEmpty { return .just(.empty)}
		if email.isValidEmail() { return .just(.ok(message: "Validation ok"))}
		return .just(.failed(message: "Not validated"))
	}
		
	//private let validationAPI = UserValidationAPI().rx
	//		return validationAPI
	//			.validate(validationType: .emailAvailable(email: email))
	//			.flatMap { result -> Observable<ValidationResult> in
	//				let parsedResult: String
	//				do {
	//					parsedResult = try result.get()
	//				} catch {
	//					return .just(.empty)
	//				}
	//				if parsedResult 		== "email_exists" {
	//					return .just(ValidationResult.failed(message: "This email exists"))
	//				} else if parsedResult 	== "email_not_existing" {
	//					return .just(ValidationResult.ok(message: ":)"))
	//				}
	//				return .just(.failed(message: "Not validated"))
	//		}

	func validatedPassword(_ password: String) -> ValidationResult {
		let numberOfCharacters = password.count
		if numberOfCharacters == 0 {
			return .empty
		}

		if numberOfCharacters < minPasswordCount {
			return .failed(message: "Password should be at least \(minPasswordCount) characters")
		}
		return .ok(message: ":)")
	}

	func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult {
		if repeatedPassword.isEmpty {
			return .empty
		}
		if repeatedPassword == password {
			return .ok(message: "Password repeated")
		}
		return .failed(message: "Password different")
	}
}
