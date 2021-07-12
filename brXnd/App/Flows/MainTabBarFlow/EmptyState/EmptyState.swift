//
//  EmptyState.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-07.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import EmptyStateKit

enum BRXNDEmptyState: CustomState {

	case notLoggedInSocialMedia
	//case noInternet etc...

	var image: UIImage? {
		switch self {
		case .notLoggedInSocialMedia:
			return UIImage()
		}
	}

	var title: String? {
		switch self {
		case .notLoggedInSocialMedia: return "Not logged-in social media"
		}
	}

	var description: String? {
		switch self {
		case .notLoggedInSocialMedia: return "Please log-in in social media first"
		}
	}

	var titleButton: String? {
		switch self {
		case .notLoggedInSocialMedia: return "Log-in now"
		}
	}
}

extension BRXNDEmptyState {
	static func socialMediaFormat() -> EmptyStateFormat {
		var format = EmptyStateFormat()
		format.backgroundColor = BRXNDColors.veryLightBlue
		format.imageSize = CGSize(width: 0, height: 0)
		format.buttonWidth = 120
		format.buttonColor = BRXNDColors.LayerColors.blueBerry
		return format
	}
	static func studioFormat() -> EmptyStateFormat {
		let format = EmptyStateFormat()
		//
		return format
	}
}
