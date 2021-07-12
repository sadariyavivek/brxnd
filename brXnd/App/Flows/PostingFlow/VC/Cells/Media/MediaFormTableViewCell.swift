//
//  MediaFormTableViewCell.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-20.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import  UIKit

final class MediaFormTableViewCell: UITableViewCell {

	@IBOutlet weak var mediaImage: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
		self.selectionStyle = .none
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

	//	func configureWith(form: MediaForm) {
	//		self.mediaImage.image = form.image
	//	}

}
