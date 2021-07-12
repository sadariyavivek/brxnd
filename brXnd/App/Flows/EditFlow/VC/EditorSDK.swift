//
//  EditorSDK.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import PhotoEditorSDK

protocol PhotoEditorView: BaseView {}
extension PhotoEditViewController: PhotoEditorView {}

final class EditorSDKConfig {

	public static let shared = EditorSDKConfig()

	/// mutated by StudioViewModel
	var currentBrandLogoURL: URL?

	private init () {
		///remove default emoticons, called once.
		StickerCategory.all.removeAll(where: { $0.title == "Emoticons"})
	}

	func retrieveBrandLogo() {
		StickerCategory.all.removeAll(where: {$0.title == "Brand"})
		if let url = currentBrandLogoURL {
			var categories = StickerCategory.all
			let brand = Sticker(imageURL: url, thumbnailURL: nil, identifier: "Logo")
			let brandCategory = StickerCategory(title: "Brand", imageURL: url, stickers: [brand])
			categories.append(brandCategory)
			StickerCategory.all = categories
		}
	}
	
	let config = Configuration { builder in
		builder.theme = .light
		builder.theme.backgroundColor = BRXNDColors.veryLightBlue
		builder.theme.toolbarBackgroundColor = BRXNDColors.veryLightBlue

		builder.configureStickerToolController { stickerControllerBuilder in
			stickerControllerBuilder.personalStickersEnabled = true
		}
		
		builder.configurePhotoEditViewController { options in
			options.actionButtonConfigurationClosure = { cell, menuItem in
				switch menuItem {
				case .tool(let toolMenuItem):
					if toolMenuItem.toolControllerClass == StickerToolController.self {
						cell.captionTextLabel.text = "Brand"
					}
				default:
					break
				}
			}
		}
	}
}
