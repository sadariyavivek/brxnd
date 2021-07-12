//
//  PagesCollectionViewCell.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-28.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Nuke

final class PagesCollectionViewCell: UICollectionViewCell {

	let label = UILabel()
	let image = UIImageView()

	//	var disposeBag = DisposeBag()

	lazy var stackView: UIStackView = {
		return UIStackView(arrangedSubviews: [image, label])
	}()

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		stackView.translatesAutoresizingMaskIntoConstraints = false
		image.translatesAutoresizingMaskIntoConstraints = false
		label.translatesAutoresizingMaskIntoConstraints = false

		addSubview(stackView)

		stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
		stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
		stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
		stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true

		image.heightAnchor.constraint(equalToConstant: 50).isActive = true

		setupUI()
	}

	override func prepareForReuse() {
		//		disposeBag = DisposeBag()
		image.image = nil
		super.prepareForReuse()
	}

	private func setupUI() {

		stackView.axis = .vertical
		stackView.spacing = 0
		stackView.distribution = .fillProportionally

		label.textAlignment = .center
		label.font = BRXNDFonts.sourceSansProsemiBold13
		label.textColor = BRXNDColors.dark

		image.contentMode = .scaleAspectFit
		//
		//		image.layer.borderWidth = 1
		//		image.layer.masksToBounds = false
		//		image.layer.borderColor = UIColor.blue.withAlphaComponent(0.5).cgColor
		//image.layer.cornerRadius = image.frame.size.height / 2
		image.clipsToBounds = true
	}

	func configure(with post: PostPage) {
		label.text = post.name
		if let url = URL(string: post.picture.url) {

			let req = ImageRequest(url: url, processors: [
				ImageProcessor.Resize(size: CGSize(width: 50, height: 50)),
				ImageProcessor.Circle()
				])

			Nuke.loadImage(with: req, into: image)
		}
	}
}
