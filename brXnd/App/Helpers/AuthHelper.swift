//
//  AuthHelper.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-21.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//
import SwiftKeychainWrapper

enum KeychainAuthResult: Error {
	case success
	case fail
	case failWithReason(Error)
}

private struct Auth {
	static let user = "usr"
}

public final class AuthHelper {

	static func retrieveUser() -> User? {

		let decoder = JSONDecoder()
		do {
			guard
				let data = KeychainWrapper.standard.data(forKey: Auth.user) else { return nil }
				let user = try decoder.decode(User.self, from: data)
				return user
		} catch let err {
			print("Error: \(err)")
		}
		return nil
	}
	
	@discardableResult
	static func saveUser(_ user: User?) -> KeychainAuthResult {

		let encoder = JSONEncoder()
		do {
			let encodedUser = try encoder.encode(user)
			let savedResult: Bool = KeychainWrapper.standard.set(encodedUser, forKey: Auth.user)
			if savedResult {return KeychainAuthResult.success}
		} catch let err {
			return KeychainAuthResult.failWithReason(err)
		}
		return KeychainAuthResult.fail
	}

	static func removeCurrentUser() { KeychainWrapper.standard.removeObject(forKey: Auth.user)}
}
