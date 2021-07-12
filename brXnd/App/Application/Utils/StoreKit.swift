//
//  StoreKit.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-31.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import StoreKit

struct StoreKitHelper {

	static let numberOfTimesLaunchedKey = "numberOfTimesLaunched"

	static func tryShowStoreKit() {

		let lastVersionKey: String = "lastVersion"

		guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else {
			#if DEBUG
			fatalError("Expected to find a bundle version in the info dictionary") 
			#else
			return
			#endif
		}

		let lastVersionPromptedForReview = UserDefaults.standard.integer(forKey: lastVersionKey)
		let numberOfTimesLaunched: Int = UserDefaults.standard.integer(forKey: StoreKitHelper.numberOfTimesLaunchedKey)

		if numberOfTimesLaunched > 3 && currentVersion != String(lastVersionPromptedForReview) {
			SKStoreReviewController.requestReview()
			UserDefaults.standard.set(currentVersion, forKey: lastVersionKey)
		}

	}

	static func incrementNumberOfTimesLaunched() {
		let numberOfTimesLaunched: Int = UserDefaults.standard.integer(forKey: StoreKitHelper.numberOfTimesLaunchedKey) + 1
		UserDefaults.standard.set(numberOfTimesLaunched, forKey: StoreKitHelper.numberOfTimesLaunchedKey)
	}
}
