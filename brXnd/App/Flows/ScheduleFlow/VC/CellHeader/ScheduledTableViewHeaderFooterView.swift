//
//  ScheduledTableViewHeaderFooterView.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-24.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class ScheduledTableViewHeaderFooterView: UITableViewHeaderFooterView {

	static let reuseIdentifier = "ScheduleFooterScheduleFooter"

	@IBOutlet weak var pageImageView: UIImageView!
	@IBOutlet weak var socialMediaIcon: UIImageView!
	@IBOutlet weak var pageTitle: UILabel!

	/*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
