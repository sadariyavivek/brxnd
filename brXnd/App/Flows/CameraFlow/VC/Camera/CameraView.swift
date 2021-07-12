//
//  CameraView.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-20.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol CameraView: BaseView {
	var onTakePhotoTapped: ((TemporaryPhotoItem) -> Void)? {get set}
	var onCancelTapped: (() -> Void)? {get set}
	var onSwitchCameraTypeTapped: (() -> Void)? {get set}
}

protocol CameraPreview: BaseView {
	var onSaveToAppTapped: ((PhotoMediaItem) -> Void)? {get set}
	var onDiscardTapped: (() -> Void)? {get set}
}
