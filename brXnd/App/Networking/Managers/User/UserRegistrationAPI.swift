//
//  UserRegistrationAPI.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-03-22.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct UserRegistrationAPI {
	let router = NetworkRouter<UserEndPoint>()
}

extension UserRegistrationAPI {
	func signUp(username: String, email: String, password: String,
				// TODO: - Should refactor the response
		completion: @escaping (_ response: Result<String, Error>) -> Void ) {

		//clear cookies before each registration request
		HTTPCookieStorage
			.shared
			.cookies?
			.forEach {HTTPCookieStorage.shared.deleteCookie($0)}
		
		router.request(.registration(username: username, password: password, email: email)) { (data, response, error) in
			if let error = error {
				completion(Result.failure(error))
				return
			}
			if let response = response as? HTTPURLResponse {
				let result 	= NetworkResponse.handleNetworkResponse(response)
				switch result {
				case .success:
					guard let data = data else {
						return completion(Result.failure(NetworkResponse.noData))}
					do {
						let stringFromData = String(decoding: data, as: UTF8.self)
						if checkForEmailConfirmation(string: stringFromData) {completion(Result.success(Regex.passed.rawValue))} else {completion(Result.failure(Regex.failed))}
					}
				case .failure(let err):
					completion(Result.failure(err))
				}
			}
		}
	}
}

fileprivate enum Regex: String, Error {
	case passed = "Regex OK"
	case failed
}

extension Regex {}

fileprivate func checkForEmailConfirmation(string: String) -> Bool {
	return string.contains("please check your email for a verification link")
}

/* https://www.regex-generator.com */

//	let regexString = ""
//	do {
//		let regex = try NSRegularExpression(pattern: regexString, options: .caseInsensitive)
//		return regex.firstMatch(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range:
//		NSRange(location: 0, length: string.count)) != nil
//	} catch {
//		return false
//	}

extension UserRegistrationAPI {
	func facebookUserDataUpload(email: String, name: String,
								token: String, avatar: String? = nil, completion: @escaping (Result<BRXNDFBAccUploadResponse, Error>) -> Void) {
		router.request(.facebookUserDataUpload(email: email, name: name, token: token, avatar: avatar)) { data, response, error in

			if let err = error {
				completion(Result.failure(err))
				return
			}

			if let response = response as? HTTPURLResponse {
				let result = NetworkResponse.handleNetworkResponse(response)

				switch result {
				case .success:
					guard let data = data else { completion(Result.failure(NetworkResponse.noData))
						return
					}
					do {
						completion(Result.success(try BRXNDFBAccUploadResponse(data: data)))
					} catch let err {
						completion(Result.failure(err))
					}
				case .failure(let networkFailureError):
					completion(Result.failure(networkFailureError))
				}
			}
		}
	}
}
