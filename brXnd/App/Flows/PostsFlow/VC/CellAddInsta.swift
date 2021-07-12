

import UIKit

class CellAddInsta: UITableViewCell {

    @IBOutlet weak var btnAttachMedia: UIButton!
    @IBOutlet weak var btnEditSchedulePost: UIButton!
    @IBOutlet weak var lblscheduleddt: UILabel!
    @IBOutlet weak var cnstlblscheduleddt: NSLayoutConstraint!
    @IBOutlet weak var tvdescription: UITextView!
    @IBOutlet weak var imgckbox: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
