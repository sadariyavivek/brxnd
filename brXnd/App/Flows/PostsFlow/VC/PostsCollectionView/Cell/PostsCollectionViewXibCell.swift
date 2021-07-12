//
//  PostsCollectionViewXibCell
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-05.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Nuke

final class PostsCollectionViewXibCell: UICollectionViewCell {

	@IBOutlet weak var cellView: UIView!
	@IBOutlet weak var imageStackView: UIStackView!
	@IBOutlet weak var imageContainerStackView: UIStackView!
	@IBOutlet weak var sourceIcon: UIImageView!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var textView: UITextView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func prepareForReuse() {
		imageStackView.subviews.forEach { view in
			view.removeFromSuperview()
		}
		super.prepareForReuse()
	}

	override func layoutSubviews() {
		setupUI()
	}

	private func setupUI() {
		
		subviews.forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}

		cellView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		cellView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		cellView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		cellView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

		cornerRadius = 8
		backgroundColor = BRXNDColors.white

	}

	public static func cellImageConfigurator(with url: String?, in stackView: UIStackView) {
		if let unwrappedURL = url, let string = URL(string: unwrappedURL) {
			let imageView = UIImageView()
			Nuke.loadImage(with: string, into: imageView)
			imageView.cornerRadius = 8
			imageView.sizeToFit()
			imageView.clipsToBounds = true
			imageView.contentMode = .scaleAspectFill
			stackView.addArrangedSubview(imageView)
		}
	}

	func configure(with post: FeedData) {

		textView.text = post.message

		if let date = post.createdTime.days(sinceDate: Current.date())?.magnitude {
			if date == 0 {
				timeLabel.text = "Today"
			} else {
				timeLabel.text = "\(date) days ago"
			}
		} else {
			timeLabel.text = post.createdTime.description
		}

		///limitation of the API
		if let attachements = post.attachments {
			switch (attachements.data.count,
					attachements.data[0].subattachments?.data.count) {
			case (1, nil):
				attachements.data.forEach { postData in
					PostsCollectionViewXibCell.cellImageConfigurator(with: postData.media?.image.src, in: imageStackView)
				}
			case (1, let value):
				guard let val = value, val > 0 else { return }
				attachements.data.forEach { postData in
					postData.subattachments?.data.forEach({ subData in
						PostsCollectionViewXibCell.cellImageConfigurator(with: subData.media.image.src, in: imageStackView)
					})
				}
			default:
				break
			}
		} else {
			//TODO: Self-resizing cell
			#if DEBUG
			print("🔥 Cell should be resized! ")
			#endif
		}
	}
}
