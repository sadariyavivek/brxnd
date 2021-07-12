//
//  VideoView.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-04-08.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol VideoView: BaseView {
	var onTakeVideoTapped: ((VideoMediaItem) -> Void)? {get set}
	var onCancelTapped: (() -> Void)? {get set}
	var onSwitchCameraTypeTapped: (() -> Void)? {get set}
}

protocol VideoPreview: BaseView {
	var onSaveToAppTapped: ((VideoMediaItem) -> Void)? {get set}
	var onDiscardTapped: (() -> Void)? {get set}
}
