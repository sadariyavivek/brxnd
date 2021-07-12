//
//  SettingsCoordinatorOutput.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-05-14.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol SettingsCoordinatorOutput: class {
	var finishFlow: (() -> Void)? { get set }
	var onShowTutorial: (() -> Void)? { get set }
}
