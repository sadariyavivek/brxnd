//
//  PostViewController.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-12.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Action
import NVActivityIndicatorView

final class PostEditViewController: UIViewController,
PostEditView,
NVActivityIndicatorViewable,
BindableType {

	@IBOutlet weak var imageStackView: UIStackView!
	@IBOutlet weak var sourceIcon: UIImageView!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var textView: UITextView!

	public var isPublishNowButtonAvailable: Bool = false

	var viewModel: PostsEditViewModelType!

	private let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupComponents()

		let output = viewModel
			.output

		configureView(with: output.postData)

		bindViewModel()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.stopAnimating()
	}

	func bindViewModel() {
		let output = viewModel
			.output

		output
			.isLoading
			.drive(onNext: { [weak self] loading in
				if loading { self?.animateLoading() } else { self?.stopAnimating() }
			}).disposed(by: disposeBag)

		output
			.deleteResponse
			.drive()
			.disposed(by: disposeBag)

		if isPublishNowButtonAvailable {
			output
				.publishResponse
				.drive()
				.disposed(by: disposeBag)
		}

	}

	private func setupUI() {}

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
			.bind(to: viewModel.input.onDeleteTapSubject)
			.disposed(by: disposeBag)

		var leftBarButtonItem = UIBarButtonItem(title: "Done",
												style: .done,
												target: self,
												action: nil)

		leftBarButtonItem
			.rx
			.action = viewModel.input.onDoneTapAction

		if self.isPublishNowButtonAvailable {
			let publishNowBarButtonItem = UIBarButtonItem(title: "Publish now",
														  style: .done,
														  target: self,
														  action: nil)
			publishNowBarButtonItem
				.rx
				.tap
				.bind(to: viewModel.input.onPublishTapSubject)
				.disposed(by: disposeBag)

			navigationItem.leftBarButtonItems = [leftBarButtonItem, publishNowBarButtonItem]
		} else {
			navigationItem.leftBarButtonItem = leftBarButtonItem
		}
	}

	private func animateLoading() {
		DispatchQueue.main.async { [weak self] in
			guard let sSelf = self else { return }
			sSelf.startAnimating(nil, message: "Loading...",
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

	private func configureView(with post: FeedData) {

		textView.text = post.message

		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none

		timeLabel.text = "Date: \(dateFormatter.string(from: post.createdTime))"

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
		}
	}
}
