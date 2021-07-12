//
//  Posts.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import RxDataSources

struct ScheduledPosts: Codable {
	let data: [ScheduledPostsData]?
	let paging: ScheduledPostsPaging?
}

struct ScheduledPostsData: Codable {
	let scheduledPublishTime: Int?
	let id: String?

	enum CodingKeys: String, CodingKey {
		case scheduledPublishTime = "scheduled_publish_time"
		case id
	}
}

struct ScheduledPostsPaging: Codable {
	let cursors: Cursors?
}

struct ScheduledPostsCursors: Codable {
	let before, after: String?
}

// MARK: - FBPosts
struct FBPosts: Codable {
	let scheduledPosts: ScheduledPosts?
	var posts: PostsFeed

	enum CodingKeys: String, CodingKey {
		case scheduledPosts = "scheduled_posts"
		case posts
	}
}

extension FBPosts {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(FBPosts.self, from: data)
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
		posts: PostsFeed? = nil
	) -> FBPosts {
		return FBPosts(
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

// MARK: - FBPosts

struct UserData: Codable {
    let name: String?
    var createdat: String?
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case createdat = "created_at"
        case id
    }
}

struct InstaFeedMedia: Codable {
    let url: String?
    var createdat: String?
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case url
        case createdat = "created_at"
        case id
    }
}

struct InstaPostData: Codable {
    let media: [InstaFeedMedia]?
    let user: UserData
    let story: String?
    var createdat: String?
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case media
        case user
        case story
        case createdat = "created_at"
        case id
    }
}

struct InstaPosts: Codable {
    var datapost: [InstaPostData?]
    let currentpage: Int?

    enum CodingKeys: String, CodingKey {
        case datapost = "data"
        case currentpage = "current_page"
    }
}

extension InstaPosts {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(InstaPosts.self, from: data)
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
        datapost: [InstaPostData]? = nil,
        currentpage: Int?  = nil
    ) -> InstaPosts {
        return InstaPosts(
            datapost: datapost ?? self.datapost,
            currentpage: currentpage ?? self.currentpage
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Posts
struct PostsFeed: Codable {
	let picture: ProfilePicture?
	var feed: Feed?
	let id: String?
}

extension PostsFeed {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(PostsFeed.self, from: data)
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
		picture: ProfilePicture? = nil,
		feed: Feed? = nil,
		id: String? = nil
	) -> PostsFeed {
		return PostsFeed(
			picture: picture ?? self.picture,
			feed: feed ?? self.feed,
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

// MARK: - Feed
struct Feed: Codable {
	var data: [FeedData]
	let paging: Paging?
}

extension Feed {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(Feed.self, from: data)
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
		data: [FeedData]? = nil,
		paging: Paging? = nil
	) -> Feed {
		return Feed(
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

// MARK: - FeedDatum
struct FeedData: Codable {
	let attachments: PostAttachements?
	let scheduledPublishTime: Int?
	let message: String?
	let adminCreator: AdminCreator?
	let from: From
	let createdTime: Date
	let id: String

	enum CodingKeys: String, CodingKey {
		case attachments, message
		case scheduledPublishTime = "scheduled_publish_time"
		case adminCreator = "admin_creator"
		case from
		case createdTime = "created_time"
		case id
	}
}

extension FeedData {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(FeedData.self, from: data)
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
		attachments: PostAttachements? = nil,
		message: String? = nil,
		adminCreator: AdminCreator? = nil,
		scheduledPublishTime: Int? = nil,
		from: From? = nil,
		createdTime: Date? = nil,
		id: String? = nil
	) -> FeedData {
		return FeedData(
			attachments: attachments ?? self.attachments,
			scheduledPublishTime: scheduledPublishTime ?? self.scheduledPublishTime,
			message: message ?? self.message,
			adminCreator: adminCreator ?? self.adminCreator,
			from: from ?? self.from,
			createdTime: createdTime ?? self.createdTime,
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

// MARK: - AdminCreator
struct AdminCreator: Codable {
	let category: String?
	let link: String?
	let name: String?
	let namespace: String?
	let id: String?
}

// MARK: AdminCreator convenience initializers and mutators

extension AdminCreator {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(AdminCreator.self, from: data)
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
		category: String? = nil,
		link: String? = nil,
		name: String? = nil,
		namespace: String? = nil,
		id: String? = nil
	) -> AdminCreator {
		return AdminCreator(
			category: category ?? self.category,
			link: link ?? self.link,
			name: name ?? self.name,
			namespace: namespace ?? self.namespace,
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

// MARK: - ScheduledPosts
struct PostAttachements: Codable {
	let data: [PostData]
}

extension PostAttachements {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(PostAttachements.self, from: data)
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
		data: [PostData]? = nil
	) -> PostAttachements {
		return PostAttachements(
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

// MARK: - PostData
struct PostData: Codable {
	let title: String?
	let url: String?
	let media: Media?
	let mediaType: String?
	let subattachments: Subattachments?

	enum CodingKeys: String, CodingKey {
		case title, url, media
		case mediaType = "media_type"
		case subattachments
	}
}

extension PostData {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(PostData.self, from: data)
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
		title: String? = nil,
		url: String? = nil,
		media: Media?? = nil,
		mediaType: String? = nil,
		subattachments: Subattachments?? = nil
	) -> PostData {
		return PostData(
			title: title ?? self.title,
			url: url ?? self.url,
			media: media ?? self.media,
			mediaType: mediaType ?? self.mediaType,
			subattachments: subattachments ?? self.subattachments
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

// MARK: - Media
struct Media: Codable {
	let image: Image
}

extension Media {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(Media.self, from: data)
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
		image: Image? = nil
	) -> Media {
		return Media(
			image: image ?? self.image
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

// MARK: - Image
struct Image: Codable {
	let height: Int?
	let src: String?
	let width: Int?
}

extension Image {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(Image.self, from: data)
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
		src: String? = nil,
		width: Int? = nil
	) -> Image {
		return Image(
			height: height ?? self.height,
			src: src ?? self.src,
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

// MARK: - Subattachments
struct Subattachments: Codable {
	let data: [SubattachmentsData]
}

extension Subattachments {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(Subattachments.self, from: data)
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
		data: [SubattachmentsData]? = nil
	) -> Subattachments {
		return Subattachments(
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

// MARK: - SubattachmentsDatum
struct SubattachmentsData: Codable {
	let datumDescription: String?
	let media: Media
	let target: Target?
	let type: String?
	let url: String?

	enum CodingKeys: String, CodingKey {
		case datumDescription = "description"
		case media, target, type, url
	}
}

extension SubattachmentsData {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(SubattachmentsData.self, from: data)
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
		datumDescription: String? = nil,
		media: Media? = nil,
		target: Target? = nil,
		type: String? = nil,
		url: String? = nil
	) -> SubattachmentsData {
		return SubattachmentsData(
			datumDescription: datumDescription ?? self.datumDescription,
			media: media ?? self.media,
			target: target ?? self.target,
			type: type ?? self.type,
			url: url ?? self.url
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

// MARK: - Target
struct Target: Codable {
	let id: String?
	let url: String?
}

extension Target {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(Target.self, from: data)
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
		id: String? = nil,
		url: String? = nil
	) -> Target {
		return Target(
			id: id ?? self.id,
			url: url ?? self.url
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

// MARK: - From
struct From: Codable {
	let name: String
	let id: String
}

extension From {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(From.self, from: data)
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
		name: String? = nil,
		id: String? = nil
	) -> From {
		return From(
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

// MARK: - Paging
struct Paging: Codable {
	let cursors: Cursors?
	let next: String?
}

extension Paging {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(Paging.self, from: data)
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
		cursors: Cursors? = nil,
		next: String? = nil
	) -> Paging {
		return Paging(
			cursors: cursors ?? self.cursors,
			next: next ?? self.next
		)
	}

	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}

	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

// MARK: - Cursors
struct Cursors: Codable {
	let before, after: String
}

extension Cursors {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(Cursors.self, from: data)
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
		before: String? = nil,
		after: String? = nil
	) -> Cursors {
		return Cursors(
			before: before ?? self.before,
			after: after ?? self.after
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
struct ProfilePicture: Codable {
	let data: PictureData?
}

extension ProfilePicture {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(ProfilePicture.self, from: data)
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
		data: PictureData? = nil
	) -> ProfilePicture {
		return ProfilePicture(
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

// MARK: - DataClass
struct PictureData: Codable {
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

extension PictureData {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(PictureData.self, from: data)
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
	) -> PictureData {
		return PictureData(
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

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
	let decoder = JSONDecoder()
	if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
		decoder.dateDecodingStrategy = .iso8601
	}
	return decoder
}

func newJSONEncoder() -> JSONEncoder {
	let encoder = JSONEncoder()
	if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
		encoder.dateEncodingStrategy = .iso8601
	}
	return encoder
}

extension FBPosts: IdentifiableType {
	var identity: String {
		#if DEBUG
		return self.posts.id!
		#else
		return self.posts.id ?? ""
		#endif
	}
}

extension FBPosts: Equatable {
	static func == (lhs: FBPosts, rhs: FBPosts) -> Bool {
		return lhs.posts.id == rhs.posts.id
	}
}

extension FeedData: IdentifiableType {
	var identity: String {
		return self.id
	}
}

extension FeedData: Equatable {
	static func == (lhs: FeedData, rhs: FeedData) -> Bool {
		return lhs.id == rhs.id
	}
}
