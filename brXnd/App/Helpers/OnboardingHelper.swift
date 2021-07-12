//
//  OnboardingHelper.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-22.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

private struct Onboarding {
	static let wasOnBoardingShown: String = "onboarding"
}

public final class OnboardingHelper {
	static func wasOnboardingShown() -> Bool {
		return UserDefaults.standard.bool(forKey: Onboarding.wasOnBoardingShown)
	}
	
	static func setOnboardingStatus(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Onboarding.wasOnBoardingShown)
	}
	
}
