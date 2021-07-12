//
//  CameraModuleFactory.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-20.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol CameraModuleFactory {
	func makeCameraModule() -> CameraView 
	func makeCameraPreview(photoItem: TemporaryPhotoItem) -> CameraPreview

//	func makeVideoCameraModule() -> VideoView
//	func makeVideoCameraPreview(videoURL: VideoMediaItem) -> VideoPreview
}
