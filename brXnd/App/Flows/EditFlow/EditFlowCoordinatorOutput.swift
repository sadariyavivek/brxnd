//
//  EditFlowCoordinatorOutput.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-05-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol EditFlowCoordinatorOutput: class {
	var finishFlow: ((_ needsUpdateOnExit: Bool) -> Void)? { get set }
	var onPostingFlow: ((_ mediaItem: MediaItem) -> Void)? { get set }
}
