//
//  UICollectionViewExtensions.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-04-29.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

extension UICollectionView {

	func setEmptyView(title: String, message: String, messageImage: UIImage) {
		let emptyView = UIView(frame: CGRect(x: center.x, y: center.y, width: bounds.size.width, height: bounds.size.height))

		let messageImageView = UIImageView()
		let titleLabel = UILabel()
		let messageLabel = UILabel()

		messageImageView.backgroundColor = .clear

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		messageImageView.translatesAutoresizingMaskIntoConstraints = false
		messageLabel.translatesAutoresizingMaskIntoConstraints = false

		titleLabel.textColor = UIColor.lightGray
		//titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)

		messageLabel.textColor = UIColor.lightGray
		//messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)

		emptyView.addSubview(titleLabel)
		emptyView.addSubview(messageImageView)
		emptyView.addSubview(messageLabel)

		messageImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
		messageImageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -50).isActive = true
		messageImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
		messageImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true

		titleLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 20).isActive = true
		titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true

		messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
		messageLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true

		messageImageView.image = messageImage
		titleLabel.text = title
		messageLabel.text = message
		messageLabel.numberOfLines = 0
		messageLabel.textAlignment = .center

		UIView.animate(withDuration: 1, animations: {
			messageImageView.transform = CGAffineTransform(rotationAngle: .pi / 10)
		}, completion: { (_) in
			UIView.animate(withDuration: 1, animations: {
				messageImageView.transform = CGAffineTransform(rotationAngle: -1 * (.pi / 10))
			}, completion: { (_) in
				UIView.animate(withDuration: 1, animations: {
					messageImageView.transform = CGAffineTransform.identity
				})
			})

		})
		backgroundView = emptyView
	}
	func restore() {
		backgroundView = nil
	}
}

public typealias CellID = Int

extension UICollectionView {
	public func getCell(for indexPath: IndexPath) -> UICollectionViewCell? {
		let cell = self.cellForItem(at: indexPath)
		return cell
	}
}
