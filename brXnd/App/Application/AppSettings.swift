//
//  AppSettings.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-19.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

fileprivate struct AppSettingConstants {
	static let wasFacebookDataUploaded: String = "facebookDataUploaded"
}

public final class AppSettings {

	public static let shared = AppSettings()

	private init() { }

	// called once, after the facebook log in
	func wasFacebookDataUploaded() -> Bool {
		return UserDefaults.standard.bool(forKey: AppSettingConstants.wasFacebookDataUploaded)
	}

	func setFacebookDataUploaded(_ value: Bool) {
		UserDefaults.standard.set(value, forKey: AppSettingConstants.wasFacebookDataUploaded)
	}

}
