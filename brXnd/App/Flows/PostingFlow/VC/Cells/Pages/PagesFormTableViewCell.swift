//
//  PagesFormTableViewCell.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-19.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Nuke
import Former

final class PagesFormableRow<T: UITableViewCell & CheckFormableRow>: CheckRowFormer<T> {

	final var postPage: PostPage!

	override func update() {
		super.update()
	}

	override func cellSelected(indexPath: IndexPath) {
		super.cellSelected(indexPath: indexPath)
		self.onPostSelected?(postPage)
	}

	public final func onPostPageSelected(_ handler: @escaping (PostPage) -> Void) -> Self {
		onPostSelected = handler
		return self
	}

	// MARK: - Private
	private final var onPostSelected: ((PostPage) -> Void)?
}

final class PagesFormTableViewCell: UITableViewCell, CheckFormableRow {

	@IBOutlet weak var pageImage: UIImageView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var icon: UIImageView!
	
	@IBOutlet weak var cellView: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

	public func configureImage(with url: String) {

		if let url = URL(string: url) {
			let req = ImageRequest(url: url, processors: [
				ImageProcessor.Resize(size: CGSize(width: 50, height: 50)),
				ImageProcessor.Circle()
			])
			Nuke.loadImage(with: req, into: pageImage)
		}
	}

	func formTitleLabel() -> UILabel? {
		return self.title
	}

	func updateWithRowFormer(_ rowFormer: RowFormer) {
		//
	}
	
}
