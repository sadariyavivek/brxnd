//
//  PostingFormHeaderFooterView.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-18.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Former

final class PostingFormHeaderFooterView: UITableViewHeaderFooterView, LabelFormableView {

	static let reuseIdentifier = "postingFormHeaderFooterView"

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var headerView: UIView!

	func formTitleLabel() -> UILabel {
		return self.titleLabel
	}

	func updateWithViewFormer(_ viewFormer: ViewFormer) {
		//
	}
}
