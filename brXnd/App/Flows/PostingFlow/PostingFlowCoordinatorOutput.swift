//
//  PostingFlowCoordinatorOutput.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-13.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol PostingFlowCoordinatorOutput: class {
	var finishFlow: ((_ needsUpdateOnExit: Bool) -> Void)? { get set }
}
