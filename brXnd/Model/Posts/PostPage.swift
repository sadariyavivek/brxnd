//
//  PostPage.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-27.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import RxDataSources

// MARK: - PostPage
public struct PostPage: Codable {
	let picture: Picture
	let name, id: String
}

// MARK: PostPage convenience initializers and mutators

extension PostPage {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(PostPage.self, from: data)
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
		picture: Picture? = nil,
		name: String? = nil,
		id: String? = nil
	) -> PostPage {
		return PostPage(
			picture: picture ?? self.picture,
			name: name ?? self.name,
			id: id ?? self.id
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

// MARK: - Picture
struct Picture: Codable {
	let height: Int
	let isSilhouette: Bool
	let url: String
	let width: Int

	enum CodingKeys: String, CodingKey {
		case height
		case isSilhouette = "is_silhouette"
		case url, width
	}
}

// MARK: Picture convenience initializers and mutators

extension Picture {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(Picture.self, from: data)
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
		height: Int? = nil,
		isSilhouette: Bool? = nil,
		url: String? = nil,
		width: Int? = nil
	) -> Picture {
		return Picture(
			height: height ?? self.height,
			isSilhouette: isSilhouette ?? self.isSilhouette,
			url: url ?? self.url,
			width: width ?? self.width
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

typealias PostPages = [PostPage]

extension Array where Element == PostPages.Element {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(PostPages.self, from: data)
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

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

extension PostPage: IdentifiableType {
	public var identity: String {
		return self.id
	}
}

extension PostPage: Equatable {
	public static func == (lhs: PostPage, rhs: PostPage) -> Bool {
		return lhs.id == rhs.id
	}
}
