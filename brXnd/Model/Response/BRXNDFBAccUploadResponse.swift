//
//  FBAccUploadResponse.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-12-03.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

// MARK: - FBAccUploadResponse
struct BRXNDFBAccUploadResponse: Codable {
    let success: Bool?
    let account: Account?
}

// MARK: FBAccUploadResponse convenience initializers and mutators

extension BRXNDFBAccUploadResponse {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(BRXNDFBAccUploadResponse.self, from: data)
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
        success: Bool?? = nil,
        account: Account?? = nil
    ) -> BRXNDFBAccUploadResponse {
        return BRXNDFBAccUploadResponse(
            success: success ?? self.success,
            account: account ?? self.account
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Account
struct Account: Codable {
    let id: Int?
    let name, email: String?
    let emailVerifiedAt: EmailVerifiedAt?
    let token: String?
    let avatar: String?
    let locale: String?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case emailVerifiedAt = "email_verified_at"
        case token, avatar, locale
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: Account convenience initializers and mutators

extension Account {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Account.self, from: data)
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
        emailVerifiedAt: EmailVerifiedAt?? = nil,
        token: String?? = nil,
        avatar: String?? = nil,
        locale: String?? = nil,
        createdAt: String?? = nil,
        updatedAt: String?? = nil
    ) -> Account {
        return Account(
            id: id ?? self.id,
            name: name ?? self.name,
            email: email ?? self.email,
            emailVerifiedAt: emailVerifiedAt ?? self.emailVerifiedAt,
            token: token ?? self.token,
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

// MARK: - EmailVerifiedAt
struct EmailVerifiedAt: Codable {
    let date: String?
    let timezoneType: Int?
    let timezone: String?

    enum CodingKeys: String, CodingKey {
        case date
        case timezoneType = "timezone_type"
        case timezone
    }
}

// MARK: EmailVerifiedAt convenience initializers and mutators

extension EmailVerifiedAt {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(EmailVerifiedAt.self, from: data)
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
        date: String?? = nil,
        timezoneType: Int?? = nil,
        timezone: String?? = nil
    ) -> EmailVerifiedAt {
        return EmailVerifiedAt(
            date: date ?? self.date,
            timezoneType: timezoneType ?? self.timezoneType,
            timezone: timezone ?? self.timezone
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
