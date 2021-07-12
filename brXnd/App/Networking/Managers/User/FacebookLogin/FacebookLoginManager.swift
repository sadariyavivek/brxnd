//
//  FacebookLoginManager.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-07.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit

fileprivate enum FacebookError: Error {
	case cancelled
	case noToken
	case failed
}

final class FacebookLoginManager {

	public static let shared = FacebookLoginManager()

	private let loginAPI: UserLoginAPI

	private init() {
		self.loginAPI = UserLoginAPI()
	}

    //, .pagesManageCta
	public func logIn(completion: @escaping (Result<Void, Error>) -> Void) {
		let loginManager = LoginManager()
		loginManager.logIn(permissions: [.publicProfile, .pagesShowList, .email], viewController: nil) { [unowned self] loginResult in
			switch loginResult {
			case .failed:
				completion(.failure(FacebookError.failed))
			case .cancelled:
				completion(.failure(FacebookError.cancelled))
			case .success(let grantedPermissions, let declinedPermissions, let accessToken):
				#if DEBUG
				print("User logged in: \(accessToken) + \(declinedPermissions) + \(grantedPermissions)")
				#endif

				self.loginAPI.getToken(provider: ProviderToken.fromFacebook(accessToken.tokenString)) { result in
					switch result {
					case .success(let webLogin):
						if let oldUser = Current.user {
							var newUser = oldUser
							newUser.webExpiresIn = webLogin.expiresIn
							newUser.webAccessToken = webLogin.accessToken
							newUser.webRefreshToken = webLogin.refreshToken
							newUser.webTokenType = webLogin.tokenType
							Current.user = newUser
						} else {
							let newUser = User(webTokenType: webLogin.tokenType,
											   webExpiresIn: webLogin.expiresIn,
											   webAccessToken: webLogin.accessToken,
											   webRefreshToken: webLogin.refreshToken)
							Current.user = newUser
						}
						#if DEBUG
						assert(Current.user?.webAccessToken != nil, "Token can't be nil")
						#endif
						completion(.success(()))
					case .failure:
						completion(.failure(FacebookError.noToken))
					}
				}
			}
		}
	}

	public func logOut() {
		let loginManager = LoginManager()
		loginManager.logOut()
	}
	
	public func profileDataRequest(completion: @escaping (Result<[String: Any], Error>) -> Void) {
		let connection = GraphRequestConnection()

		let graphRequest = GraphRequest(graphPath: "/me",
										parameters: ["fields": "id, name, email, picture"])

		connection.add(graphRequest) { _, result, error in
			#if DEBUG
			print("Result: \(String(describing: result)), \(String(describing: error))")
			#endif

			if var dict = result as? [String: Any] {

				//pass the fb token along with the dict
				dict.updateValue("\(AccessToken.current?.tokenString ?? "")", forKey: "token")

				completion(Result.success(dict))
			} else {
				#if DEBUG
				completion(Result.failure(error!))
				#else
				completion(Result.failure(error ?? NSError()))
				#endif
			}

		}

		connection.start()
	}

}
