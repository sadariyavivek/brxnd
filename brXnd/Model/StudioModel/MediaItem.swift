//
//  LibraryItem.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-20.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import AVFoundation

//used to pass the photo from the camera.
typealias TemporaryPhotoItem = (image: UIImage, settings: AVCaptureResolvedPhotoSettings)

public typealias EditorData = (Data)

public protocol MediaItem {
	var image: UIImage { get set }
	var assetModel: BrandAsset? { get }
	var mediaModifiers: MediaSource { get set }
}
extension MediaItem {
	public func asPNGImageData() -> Data {
		return self.image.pngData()!
	}
}

public enum MediaSource {
	case isEdited(_ data: EditorData?)
	case isOriginal(fromCamera: Bool?)
}

struct PhotoMediaItem: MediaItem {

	var image: UIImage
	var mediaModifiers: MediaSource

	let assetModel: BrandAsset?
	
	init(image: UIImage,
		 mediaModifiers: MediaSource,
		 assetModel: BrandAsset?) {

		self.image = image
		self.mediaModifiers = mediaModifiers
		self.assetModel = assetModel

	}
}

// not used yet
struct VideoMediaItem {
	var mediaModifiers: MediaSource
	
	let itemURL: URL
	let name: String?
	
	let fromDeviceCamera: Bool
	
	init(videoURL: URL, name: String?,
		 fromDeviceCamera: Bool = false,
		 mediaModifiers: MediaSource = MediaSource.isOriginal(fromCamera: true)) {
		self.itemURL = videoURL
		self.name = name
		self.fromDeviceCamera = fromDeviceCamera
		self.mediaModifiers = mediaModifiers
	}
}
