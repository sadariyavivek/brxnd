//
//  StudioAssetUploadResponse.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-19.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct BRXNDStudioAssetUploadResponse: Codable {
	let url: String?
	let userID: Int?
	let brandID, updatedAt, createdAt: String?
	let id: Int?
	let type: String?

	enum CodingKeys: String, CodingKey {
		case url
		case userID = "user_id"
		case brandID = "brand_id"
		case updatedAt = "updated_at"
		case createdAt = "created_at"
		case id, type
	}
}
extension BRXNDStudioAssetUploadResponse {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(BRXNDStudioAssetUploadResponse.self, from: data)
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
		url: String?? = nil,
		userID: Int?? = nil,
		brandID: String?? = nil,
		updatedAt: String?? = nil,
		createdAt: String?? = nil,
		id: Int?? = nil,
		type: String?? = nil
		) -> BRXNDStudioAssetUploadResponse {
		return BRXNDStudioAssetUploadResponse(
			url: url ?? self.url,
			userID: userID ?? self.userID,
			brandID: brandID ?? self.brandID,
			updatedAt: updatedAt ?? self.updatedAt,
			createdAt: createdAt ?? self.createdAt,
			id: id ?? self.id,
			type: type ?? self.type
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}
