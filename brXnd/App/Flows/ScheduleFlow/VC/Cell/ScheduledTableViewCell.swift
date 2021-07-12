//
//  ScheduledTableViewCell.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-24.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class ScheduledTableViewCell: UITableViewCell {

	@IBOutlet weak var postMessage: UILabel!
	@IBOutlet weak var willPostOnDate: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

	override func prepareForReuse() {
		self.postMessage.text = ""
		self.willPostOnDate.text = ""
	}

	func configureCell(with feedData: FeedData) {
		postMessage.text = feedData.message

		let dateformatter = DateFormatter()
		dateformatter.dateStyle = DateFormatter.Style.medium
		dateformatter.timeStyle = DateFormatter.Style.short

		let dateWillPost = dateformatter.string(from: feedData.createdTime)

		willPostOnDate.text = dateWillPost

	}

}
