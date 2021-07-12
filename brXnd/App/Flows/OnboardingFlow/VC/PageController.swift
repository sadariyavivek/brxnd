//
//  PageController.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-01-30.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class PageViewController: UIPageViewController,
	UIPageViewControllerDataSource,
	UIPageViewControllerDelegate,
	StepsView {
	
	var onFinishFlow: (() -> Void)?

	private var pages = [UIViewController]()
	private let pageControl = UIPageControl()

	override var transitionStyle: UIPageViewController.TransitionStyle {
		return .scroll
	}
	
	override func viewDidLoad() {
		self.dataSource = self
		self.delegate = self
		let initialPage = 0

		self.view.backgroundColor = UIColor.white

		let page1 = Page1ViewController.controllerFromStoryboard(.onboarding)
		let page2 = Page2ViewController.controllerFromStoryboard(.onboarding)
		let page3 = Page3ViewController.controllerFromStoryboard(.onboarding)

		page3.onFinishTap = { [unowned self] in
			self.onFinishFlow?()
		}

		//add the individual viewControllers to the pageViewController
		self.pages.append(page1)
		self.pages.append(page2)
		self.pages.append(page3)
		setViewControllers([pages[initialPage]], direction: .forward, animated: false, completion: nil)

//		// pageControl
//		self.pageControl.frame = CGRect()
//		self.pageControl.currentPageIndicatorTintColor = UIColor.black
//		self.pageControl.pageIndicatorTintColor = UIColor.lightGray
//		self.pageControl.numberOfPages = self.pages.count
//		self.pageControl.currentPage = initialPage
//		self.view.addSubview(self.pageControl)
//
//		self.pageControl.translatesAutoresizingMaskIntoConstraints = false
//		self.pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
//		self.pageControl.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -20).isActive = true
//		self.pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
//		self.pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
	}
}

extension PageViewController {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
			return nil
		}

		let previousIndex = viewControllerIndex - 1

		guard previousIndex >= 0 else {
			return nil
		}

		guard pages.count > previousIndex else {
			return nil
		}
		return pages[previousIndex]
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

		guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
			return nil
		}

		print(viewControllerIndex)

		let nextIndex = viewControllerIndex + 1
		let orderedViewControllersCount = pages.count

		guard orderedViewControllersCount != nextIndex else {
			return nil
		}
		guard orderedViewControllersCount > nextIndex else {
			return nil
		}
		return pages[nextIndex]
	}

//	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//
//		if let viewControllers = pageViewController.viewControllers {
//			if let viewControllerIndex = pages.firstIndex(of: viewControllers[0]) {
//				pageControl.currentPage = viewControllerIndex
//			}
//		}
//	}
}
