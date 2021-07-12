//
//  BrandAssets.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-29.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

// MARK: - BrandAssets

struct BrandAssets: Codable {
	let brand: BrandData?
	let media: [BrandAsset]?
}

extension BrandAssets {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(BrandAssets.self, from: data)
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
		brand: BrandData?? = nil,
		media: [BrandAsset]?? = nil
		) -> BrandAssets {
		return BrandAssets(
			brand: brand ?? self.brand,
			media: media ?? self.media
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

// MARK: - BrandMedia
public struct BrandAsset: Codable {
	let id: Int?
	let url: String?
	let flag: Int?
	let imageData, newImage, thumbnail: String?
	let userID, brandID: Int?
	let createdAt, updatedAt, type: String?

	enum CodingKeys: String, CodingKey {
		case id, url, flag
		case imageData = "image_data"
		case newImage = "new_image"
		case thumbnail
		case userID = "user_id"
		case brandID = "brand_id"
		case createdAt = "created_at"
		case updatedAt = "updated_at"
		case type
	}
}
extension BrandAsset {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(BrandAsset.self, from: data)
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
		url: String?? = nil,
		flag: Int?? = nil,
		imageData: String?? = nil,
		newImage: String?? = nil,
		thumbnail: String?? = nil,
		userID: Int?? = nil,
		brandID: Int?? = nil,
		createdAt: String?? = nil,
		updatedAt: String?? = nil,
		type: String?? = nil
		) -> BrandAsset {
		return BrandAsset(
			id: id ?? self.id,
			url: url ?? self.url,
			flag: flag ?? self.flag,
			imageData: imageData ?? self.imageData,
			newImage: newImage ?? self.newImage,
			thumbnail: thumbnail ?? self.thumbnail,
			userID: userID ?? self.userID,
			brandID: brandID ?? self.brandID,
			createdAt: createdAt ?? self.createdAt,
			updatedAt: updatedAt ?? self.updatedAt,
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

extension BrandAsset {
	func isEditorDataAvailable() -> Bool {
		switch self.flag {
		case 1:
			if let _ = self.imageData {
				return true
			} else {
				return false
			}
		default:
			return false
		}
	}
}
