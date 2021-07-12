//
//  PostsEndPoint.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

public typealias PageID = String
public typealias PostID = String
public typealias PostIdentifier = (PostID, PageID)
public typealias PaginationTuple = (PageID, String)

enum PostsAPIProvider {
	case retrievePostsFor(PageID)
	case newPost(NewPost)
	case retrievePaginatedPostsFor(PaginationTuple)
	case deletePost(PostIdentifier)
    case retrieveInstaPostsFor
}

extension PostsAPIProvider: EndPointType {

	var baseURL: URL {
		let url = BRXNDBaseURL.url
		return url
	}

	var path: String {
		switch self {
		case .retrievePostsFor, .newPost:
			return "/api/v1/facebook-post"
		case .deletePost:
			return "/api/v1/facebook-delete-post"
		case .retrievePaginatedPostsFor:
			return "/api/v1/facebook-timeline"
        case .retrieveInstaPostsFor:
            return "/api/v1/instagram-posts"
        }
	}

	var httpMethod: HTTPMethod {
		switch self {
        case .retrievePostsFor, .retrievePaginatedPostsFor, .retrieveInstaPostsFor:
			return .get
		case .deletePost, .newPost:
			return .post
		}
	}

	var task: HTTPTask {

		switch self {
		case .retrievePostsFor(let id):
			return .requestParametersAndHeaders(bodyParameters: nil,
												bodyEncoding: .urlEncoding,
												urlParameters: ["id": "\(id)"],
												additionalHeaders: Current.getHeadersWithAccessToken())
        case .retrieveInstaPostsFor:
        return .requestParametersAndHeaders(bodyParameters: nil,
                                            bodyEncoding: .urlEncoding,
                                            urlParameters: nil,
                                            additionalHeaders: Current.getHeadersWithAccessToken())
		case .deletePost(let pageID, let postID):
			return .requestParametersAndHeaders(bodyParameters: ["params": ["id": "\(postID)", "fbPageId": "\(pageID)"]],
												bodyEncoding: .jsonEncoding,
												urlParameters: nil,
												additionalHeaders: Current.getHeadersWithAccessToken())

		case .retrievePaginatedPostsFor(let tuple):
			return .requestParametersAndHeaders(bodyParameters: nil,
												bodyEncoding: .urlEncoding,
												urlParameters: ["id": "\(tuple.0)", "next": "\(tuple.1)"],
												additionalHeaders: Current.getHeadersWithAccessToken())

		case .newPost(let post):

			var dict: [String: Any] = [:]

			do {
				let data = try post.jsonData()
				if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
					dict = dictionary
				}
			} catch {
				//
			}
			return .requestParametersAndHeaders(bodyParameters: dict,
												bodyEncoding: .jsonEncoding,
												urlParameters: nil,
												additionalHeaders: Current.getHeadersWithAccessToken())
		}
	}

	var headers: HTTPHeaders? {
		return nil
	}
}
