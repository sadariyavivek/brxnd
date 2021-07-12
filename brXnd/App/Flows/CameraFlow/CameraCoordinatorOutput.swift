//
//  CameraCoordinatorOutput.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-20.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol CameraCoordinatorOutput: class {
	var finishFlow: ((MediaItem?) -> Void)? { get set }
}
