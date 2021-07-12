//
//  BRXNDCreateOrDeleteResponse.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-12.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct BRXNDCreateOrDeleteResponse: Codable {
	let msgTitle, msgBody, dialogType: String?
}
extension BRXNDCreateOrDeleteResponse {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(BRXNDCreateOrDeleteResponse.self, from: data)
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
		msgTitle: String?? = nil,
		msgBody: String?? = nil,
		dialogType: String?? = nil,
		brand: BrandData?? = nil
		) -> BRXNDCreateOrDeleteResponse {
		return BRXNDCreateOrDeleteResponse(
			msgTitle: msgTitle ?? self.msgTitle,
			msgBody: msgBody ?? self.msgBody,
			dialogType: dialogType ?? self.dialogType
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}
