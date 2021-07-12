//
//  SocialMediaFormTableViewCell.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-14.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class SocialMediaFormTableViewCell: UITableViewCell {

	@IBOutlet weak var socialMediaName: UILabel!
	@IBOutlet weak var socialMediaButton: UIButton!

	override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
