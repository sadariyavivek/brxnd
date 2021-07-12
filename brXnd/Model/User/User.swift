//
//  User.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-03-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import FBSDKCoreKit

struct WebLogin: Codable {
    let tokenType: String
    let expiresIn: Int
    let accessToken, refreshToken: String

    enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

protocol WebsiteUserLoginProtocol: Codable {
    var webTokenType: String? {get set}
    var webExpiresIn: Int? {get set}
    var webAccessToken: String? {get set}
    var webRefreshToken: String? {get set}
}

protocol FacebookUserLoginProtocol: Codable {
    var facebookData: AccessToken? {get}
}

protocol GoogleUserLoginProtocol: Codable {}

struct User: WebsiteUserLoginProtocol,
    FacebookUserLoginProtocol,
GoogleUserLoginProtocol {

    ///websited logged in params
    var webTokenType: String?
    var webExpiresIn: Int?
    var webAccessToken: String?
    var webRefreshToken: String?

    enum CodingKeys: String, CodingKey {
        case webTokenType = "token_type"
        case webExpiresIn = "expires_in"
        case webAccessToken = "access_token"
        case webRefreshToken = "refresh_token"
    }

    ///facebook logged in params
    var facebookData: AccessToken? {
        return AccessToken.current
    }
}

extension User {
    var isLoggedInWithFacebook: Bool {
        if facebookData == nil { return false } else { return true }
    }

    var facebookAccesTokenString: String? {
        return facebookData?.tokenString
    }

}

extension User {
    static func newUser(networkData: WebLogin) -> User {
        let newUser = User.init(webTokenType: networkData.tokenType,
                                webExpiresIn: networkData.expiresIn,
                                webAccessToken: networkData.accessToken,
                                webRefreshToken: networkData.refreshToken)
        return newUser
    }

    static func updateCurrentUser(withWebData: WebLogin, oldUser: User) -> User {

        let updatedUser = User.init(webTokenType: withWebData.tokenType,
                                    webExpiresIn: withWebData.expiresIn,
                                    webAccessToken: withWebData.accessToken,
                                    webRefreshToken: withWebData.refreshToken)
        return updatedUser
    }
}
