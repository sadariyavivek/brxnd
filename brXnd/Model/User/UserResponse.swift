//
//  UserResponse.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct UserResponse: Codable {
	let id: Int?
	let name, email, emailVerifiedAt, avatar: String?
	let locale, createdAt: String?
	let updatedAt: String?

	enum CodingKeys: String, CodingKey {
		case id, name, email
		case emailVerifiedAt = "email_verified_at"
		case avatar, locale
		case createdAt = "created_at"
		case updatedAt = "updated_at"
	}
}

extension UserResponse {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(UserResponse.self, from: data)
	}

	init(_ json: String, using encoding: String.Encoding = .utf8) throws {
		guard let data = json.data(using: encoding) else {
			throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
		}
		try self.init(data: data)
	}

	init(fromURL url: URL) throws {
		try self.init(data: try Data(contentsOf: url))
	}

	func with(
		id: Int?? = nil,
		name: String?? = nil,
		email: String?? = nil,
		emailVerifiedAt: String?? = nil,
		avatar: String?? = nil,
		locale: String?? = nil,
		createdAt: String?? = nil,
		updatedAt: String?? = nil
		) -> UserResponse {
		return UserResponse(
			id: id ?? self.id,
			name: name ?? self.name,
			email: email ?? self.email,
			emailVerifiedAt: emailVerifiedAt ?? self.emailVerifiedAt,
			avatar: avatar ?? self.avatar,
			locale: locale ?? self.locale,
			createdAt: createdAt ?? self.createdAt,
			updatedAt: updatedAt ?? self.updatedAt
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}
