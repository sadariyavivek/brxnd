//
//  NewPost.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-11.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

// MARK: - NewPost
struct NewPost: Codable {
    let facebookPageID, message: String
    let media: [UploadMedia]?
    let scheduled: Bool
    let scheduledPublishTime: String?

    enum CodingKeys: String, CodingKey {
        case facebookPageID = "facebookPageId"
        case message, media, scheduled
        case scheduledPublishTime = "scheduled_publish_time"
    }
}

// MARK: NewPost convenience initializers and mutators

extension NewPost {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(NewPost.self, from: data)
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
        facebookPageID: String,
        message: String,
        media: [UploadMedia]?,
        scheduled: Bool,
        scheduledPublishTime: String?? = nil
    ) -> NewPost {
        return NewPost(
			facebookPageID: self.facebookPageID,
			message: self.message,
            media: media ?? self.media,
            scheduled: self.scheduled,
            scheduledPublishTime: scheduledPublishTime ?? self.scheduledPublishTime
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
struct UploadMedia: Codable {
    let type, url: String?
}

// MARK: Media convenience initializers and mutators

extension UploadMedia {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UploadMedia.self, from: data)
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
        type: String?? = nil,
        url: String?? = nil
    ) -> UploadMedia {
        return UploadMedia(
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
