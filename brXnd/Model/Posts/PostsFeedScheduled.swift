//
//  PostsFeedScheduled.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-24.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

// MARK: - FBPostsScheduled
struct FBPostsScheduled: Codable {
	let scheduledPosts: FBPostsScheduledScheduledPosts?

	enum CodingKeys: String, CodingKey {
		case scheduledPosts = "scheduled_posts"
	}
}

// MARK: FBPostsScheduled convenience initializers and mutators

extension FBPostsScheduled {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(FBPostsScheduled.self, from: data)
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
		scheduledPosts: FBPostsScheduledScheduledPosts?? = nil
	) -> FBPostsScheduled {
		return FBPostsScheduled(
			scheduledPosts: scheduledPosts ?? self.scheduledPosts
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

// MARK: - FBPostsScheduledScheduledPosts
struct FBPostsScheduledScheduledPosts: Codable {
	let picture: PictureDataClass?
	let scheduledPosts: ScheduledPostsScheduledPosts?
	let id: String?

	enum CodingKeys: String, CodingKey {
		case picture
		case scheduledPosts = "scheduled_posts"
		case id
	}
}

// MARK: FBPostsScheduledScheduledPosts convenience initializers and mutators

extension FBPostsScheduledScheduledPosts {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(FBPostsScheduledScheduledPosts.self, from: data)
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
		picture: PictureDataClass?? = nil,
		scheduledPosts: ScheduledPostsScheduledPosts?? = nil,
		id: String?? = nil
	) -> FBPostsScheduledScheduledPosts {
		return FBPostsScheduledScheduledPosts(
			picture: picture ?? self.picture,
			scheduledPosts: scheduledPosts ?? self.scheduledPosts,
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
struct PictureDataClass: Codable {
    let data: Picture?
}

// MARK: Picture convenience initializers and mutators

extension PictureDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PictureDataClass.self, from: data)
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
        data: Picture?? = nil
    ) -> PictureDataClass {
        return PictureDataClass(
            data: data ?? self.data
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - ScheduledPostsScheduledPosts
struct ScheduledPostsScheduledPosts: Codable {
	let data: [FeedData]?
	let paging: Paging?
}

// MARK: ScheduledPostsScheduledPosts convenience initializers and mutators

extension ScheduledPostsScheduledPosts {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(ScheduledPostsScheduledPosts.self, from: data)
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
		data: [FeedData]?? = nil,
		paging: Paging?? = nil
	) -> ScheduledPostsScheduledPosts {
		return ScheduledPostsScheduledPosts(
			data: data ?? self.data,
			paging: paging ?? self.paging
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}
