//
//  BrandCollectionViewXibCell.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Nuke
import Device

final class BrandCollectionViewXibCell: UICollectionViewCell {

	// MARK: - Public
	var brandID: CellID?

	@IBOutlet weak var cellView: UIView!
	@IBOutlet weak var cellStackView: UIStackView!
	@IBOutlet weak var imageContainerView: UIView!

	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var image: UIImageView!

	override var isSelected: Bool {
		didSet {
			if self.isSelected && self.brandID != BRXNDMock.brand.id {
				colorTheBorder(with: .red)
			} else {
				colorTheBorder()
			}
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setupUI()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		colorTheBorder()

		self.image.image = nil
	}

	private func colorTheBorder(with color: UIColor = BRXNDColors.LayerColors.blueBerry) {
		imageContainerView.layer.borderColor = color.cgColor
		imageContainerView.layer.borderWidth = 1
	}

	private func setupUI() {

		cellView.backgroundColor = BRXNDColors.veryLightPink
		backgroundColor = BRXNDColors.veryLightPink

		label.textAlignment = .left
		label.font = BRXNDFonts.openSansRegular13
		label.textColor = BRXNDColors.black

		image.contentMode = .scaleAspectFit
		image.clipsToBounds = true

		colorTheBorder()
	}

	func configure(with item: BrandData) {
		brandID = item.id
		label.text = item.name

		switch item.id {
		case BRXNDMock.brand.id:
			image.image = BRXNDMock.brand.image
			image.backgroundColor = BRXNDColors.veryLightBlueTwo
			imageContainerView.backgroundColor = BRXNDColors.veryLightBlueTwo
		default:
			if let logoPath = item.logoPath,
				let fullURL = URL(string: BRXNDBaseURL.url.absoluteString + logoPath) {
				image.backgroundColor = BRXNDColors.veryLightPink
				imageContainerView.backgroundColor = BRXNDColors.veryLightPink
				let options = ImageLoadingOptions(
					//				placeholder: UIImage(named: "addBrand2"),
					//				failureImage: UIImage(named: "failureImage"),
					contentModes: .init(success: .scaleAspectFit, failure: .scaleAspectFit, placeholder: .scaleAspectFit)
				)
				let req = ImageRequest(url: fullURL, processors: [
					ImageProcessor.Resize(size: CGSize(width: 90, height: 90))
					])
				Nuke.loadImage(with: req, options: options, into: image)
				image.image?.withAlignmentRectInsets(UIEdgeInsets.zero)
			} else {
				image.backgroundColor = UIColor.red.withAlphaComponent(0.5)
			}
		}
	}
}
