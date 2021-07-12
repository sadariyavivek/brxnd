//
//  EditorUploadResponse.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-20.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct BRXNDEditorUploadResponse: Codable {
	let body, type: String?
}
extension BRXNDEditorUploadResponse {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(BRXNDEditorUploadResponse.self, from: data)
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
		body: String?? = nil,
		type: String?? = nil
		) -> BRXNDEditorUploadResponse {
		return BRXNDEditorUploadResponse(
			body: body ?? self.body,
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
