//
//  SocialMediaFormTableViewCell.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-14.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Former

final class SocialMediaFormTableViewCell: UITableViewCell, CheckFormableRow {

	@IBOutlet weak var socialMediaName: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()

		let backgroundColorView = UIView()
			backgroundColorView.backgroundColor = BRXNDColors.veryLightBlue
			self.selectedBackgroundView = backgroundColorView
	}

	override func prepareForReuse() {
		super.prepareForReuse()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

	func formTitleLabel() -> UILabel? {
		return self.socialMediaName
	}

	func updateWithRowFormer(_ rowFormer: RowFormer) {
		//
	}

}
