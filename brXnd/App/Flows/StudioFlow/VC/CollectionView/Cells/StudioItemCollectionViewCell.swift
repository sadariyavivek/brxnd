//
//  LibraryItemCollectionViewCell.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-03-15.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Nuke

final class StudioItemCollectionViewCell: UICollectionViewCell {
	
	// MARK: - Public
	var cellItemID: Int?
	let imageView = UIImageView()
	
	// MARK: - Private
	private let view = UIView()
	private let loadingIndicator = UIActivityIndicatorView(style: .gray)
	private let playVideoIcon = UIImageView()
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func prepareForReuse() {
		imageView.image = nil
		playVideoIcon.isHidden = true
	}
	
	override func layoutSubviews() {
		
		playVideoIcon.image = UIImage(named: "playVideoIcon")!
		
		addSubview(view)
		view.addSubview(imageView)
		view.addSubview(playVideoIcon)
		view.addSubview(loadingIndicator)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		view.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
		view.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
		view.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
		view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
		
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
		imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
		imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
		imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
		
		loadingIndicator.center = view.center
		loadingIndicator.hidesWhenStopped = true
		
		playVideoIcon.translatesAutoresizingMaskIntoConstraints = false
		playVideoIcon.widthAnchor.constraint(equalToConstant: 25).isActive = true
		playVideoIcon.heightAnchor.constraint(equalToConstant: 25).isActive = true
		
		playVideoIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		playVideoIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		
		setupUI()
	}
	
	private func setupUI() {
		imageView.backgroundColor = BRXNDColors.veryLightBlue
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		
		//		loadingIndicator.startAnimating()
		playVideoIcon.isHidden = true
	}
	
	func configure(with asset: BrandAsset) {
		
		cellItemID = asset.id
		
		var imgString: String? {
			switch asset.flag {
			///if editor generated available, show photo
			case 1:

				/* with image optimization */
				//				if let imageThumbnail = asset.thumbnail {
				//					return imageThumbnail
				//				} else {
				//					return asset.newImage
				//				}
				//
				/* without it */

				return asset.newImage
			///otherwise show original
			default:
				return asset.url
			}
		}
		
		if let imgPath = imgString,
			let fullURL = URL(string: BRXNDBaseURL.url.absoluteString + imgPath) {
			let req = ImageRequest(url: fullURL, processors: [])
			Nuke.loadImage(with: req, into: imageView)
		} else {
			#if DEBUG
			print("😓 Studio image URL can't be parsed!")
			#endif
		}
	}
}
