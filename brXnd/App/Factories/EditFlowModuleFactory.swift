//
//  EditFlowModuleFactory.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-05-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol EditFlowModuleFactory {
	func makeLibraryItemPreview(libraryItem: MediaItem) -> (EditorPreviewView, EditorPreviewViewModel)

	func makePhotoEditor(photo: PhotoMediaItem) -> PhotoEditorView
//	func makeVideoEditor(video: VideoMediaItem) -> VideoEditorView
}
