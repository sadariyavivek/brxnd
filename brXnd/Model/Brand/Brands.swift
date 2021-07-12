//
//  Brands.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-25.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct FBPages: Decodable {
    let list: [FBPage]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        print(container)
        let stringArray = try container.decode(FBPage.self)
        print(container)
        list = [stringArray]
    }
}

extension FBPages {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FBPages.self, from: data)
    }
}

struct FBPage: Codable {
    let name: String?
    let picture: PictureData?
    let id: String?
}

struct BrandResponse: Codable {
	let brands, drafts: Brands?
}

extension BrandResponse {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(BrandResponse.self, from: data)
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
		brands: Brands?? = nil,
		drafts: Brands?? = nil
		) -> BrandResponse {
		return BrandResponse(
			brands: brands ?? self.brands,
			drafts: drafts ?? self.drafts
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

// MARK: - Brands
struct Brands: Codable {
	let currentPage: Int?
	let data: [BrandData]?
	let firstPageURL: String?
	let from: Int?
	let lastPage: Int?
	let lastPageURL: String?
	let nextPageURL: String?
	let path: String?
	let perPage: Int?
	let prevPageURL: String?
	let to: Int?
	let total: Int?

	enum CodingKeys: String, CodingKey {
		case currentPage = "current_page"
		case data
		case firstPageURL = "first_page_url"
		case from
		case lastPage = "last_page"
		case lastPageURL = "last_page_url"
		case nextPageURL = "next_page_url"
		case path
		case perPage = "per_page"
		case prevPageURL = "prev_page_url"
		case to, total
	}
}

extension Brands {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(Brands.self, from: data)
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
		currentPage: Int?? = nil,
		data: [BrandData]?? = nil,
		firstPageURL: String?? = nil,
		from: Int?? = nil,
		lastPage: Int?? = nil,
		lastPageURL: String?? = nil,
		nextPageURL: String?? = nil,
		path: String?? = nil,
		perPage: Int?? = nil,
		prevPageURL: String?? = nil,
		to: Int?? = nil,
		total: Int?? = nil
		) -> Brands {
		return Brands(
			currentPage: currentPage ?? self.currentPage,
			data: data ?? self.data,
			firstPageURL: firstPageURL ?? self.firstPageURL,
			from: from ?? self.from,
			lastPage: lastPage ?? self.lastPage,
			lastPageURL: lastPageURL ?? self.lastPageURL,
			nextPageURL: nextPageURL ?? self.nextPageURL,
			path: path ?? self.path,
			perPage: perPage ?? self.perPage,
			prevPageURL: prevPageURL ?? self.prevPageURL,
			to: to ?? self.to,
			total: total ?? self.total
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

struct BrandData: Codable {
	let id, userID: Int?
	let name, datumDescription, logoPath, logo: String?
	let slug, color: String?
	let draft: Int?
	let createdAt, updatedAt: String?

	enum CodingKeys: String, CodingKey {
		case id
		case userID = "user_id"
		case name
		case datumDescription = "description"
		case logoPath = "logo_path"
		case logo, slug, color, draft
		case createdAt = "created_at"
		case updatedAt = "updated_at"
	}
}

extension BrandData {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(BrandData.self, from: data)
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
		userID: Int?? = nil,
		name: String?? = nil,
		datumDescription: String?? = nil,
		logoPath: String?? = nil,
		logo: String?? = nil,
		slug: String?? = nil,
		color: String?? = nil,
		draft: Int?? = nil,
		createdAt: String?? = nil,
		updatedAt: String?? = nil
		) -> BrandData {
		return BrandData(
			id: id ?? self.id,
			userID: userID ?? self.userID,
			name: name ?? self.name,
			datumDescription: datumDescription ?? self.datumDescription,
			logoPath: logoPath ?? self.logoPath,
			logo: logo ?? self.logo,
			slug: slug ?? self.slug,
			color: color ?? self.color,
			draft: draft ?? self.draft,
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
