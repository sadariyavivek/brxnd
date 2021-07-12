//
//  PostsFeedPaginated.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-21.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct FBPostsPaginated: Codable {
	let scheduledPosts: ScheduledPosts?
	let posts: Feed

	enum CodingKeys: String, CodingKey {
		case scheduledPosts = "scheduled_posts"
		case posts
	}
}

extension FBPostsPaginated {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(FBPostsPaginated.self, from: data)
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
		scheduledPosts: ScheduledPosts? = nil,
		posts: Feed? = nil
		) -> FBPostsPaginated {
		return FBPostsPaginated(
			scheduledPosts: scheduledPosts ?? self.scheduledPosts,
			posts: posts ?? self.posts
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}
