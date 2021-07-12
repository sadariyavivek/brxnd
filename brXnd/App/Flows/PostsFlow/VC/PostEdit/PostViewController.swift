//
//  PostViewController.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-12.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import NVActivityIndicatorView

protocol PostEditView: BaseView {
	var onDoneTap: (() -> Void)? { get set }
	var onDeleteTap: (() -> Void)? { get set }
}

final class PostEditViewController: UIViewController, PostEditView, NVActivityIndicatorViewable {

	var post: FeedData!

	@IBOutlet weak var imageStackView: UIStackView!
	@IBOutlet weak var sourceIcon: UIImageView!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var textView: UITextView!

	var onDoneTap: (() -> Void)?
	var onDeleteTap: (() -> Void)?

	private let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupComponents()
		configureView()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.stopAnimating()
	}

	private func setupUI() {
		//
	}

	private func setupComponents() {
		let rightBarButtonItem = UIBarButtonItem(title: "Delete",
												 style: .plain,
												 target: self,
												 action: nil)
		var attributes = [NSAttributedString.Key: AnyObject]()
		attributes[.foregroundColor] = UIColor.red
		rightBarButtonItem.setTitleTextAttributes(attributes,
												  for: [.normal])
		navigationItem.rightBarButtonItem = rightBarButtonItem

		rightBarButtonItem
			.rx
			.tap
			.take(1)
			.subscribe(onNext: { [weak self] in
				self?.deletePost()
			}).disposed(by: disposeBag)

		let leftBarButtonItem = UIBarButtonItem(title: "Done",
												style: .done,
												target: self,
												action: nil)
		navigationItem.leftBarButtonItem = leftBarButtonItem

		leftBarButtonItem
			.rx
			.tap
			.subscribe(onNext: { [weak self] in
				self?.onDoneTap?()
			}).disposed(by: disposeBag)
	}

	// MARK: - Delete post
	private func deletePost() {
		let api = PostsAPI()
		animateLoading()
		api.deletePost(for: (post.from.id, post.id)) { [weak self] _ in
			self?.onDeleteTap?()
		}
	}
	private func animateLoading() {
		DispatchQueue.main.async { [weak self] in
			guard let sSelf = self else { return }
			sSelf.startAnimating(nil, message: "Deleting...",
								 messageFont: nil,
								 type: .circleStrokeSpin,
								 color: nil, padding: nil,
								 displayTimeThreshold: nil,
								 minimumDisplayTime: nil,
								 backgroundColor: nil,
								 textColor: nil,
								 fadeInAnimation: nil)
		}
	}

	private func configureView() {

		textView.text = post.message

		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none

		timeLabel.text = "Posted: \(dateFormatter.string(from: post.createdTime))"

		switch (post.attachments.data.count,
				post.attachments.data[0].subattachments?.data.count) {
		case (1, nil):
			post.attachments.data.forEach { postData in
				PostsCollectionViewXibCell.cellImageConfigurator(with: postData.media?.image.src, in: imageStackView)
			}
		case (1, let value):
			guard let val = value, val > 0 else { return }
			post.attachments.data.forEach { postData in
				postData.subattachments?.data.forEach({ subData in
					PostsCollectionViewXibCell.cellImageConfigurator(with: subData.media.image.src, in: imageStackView)
				})
			}
		default:
			break
		}
	}
}
