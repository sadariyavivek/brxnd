//
//  PinterestStyleLayout.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-03-15.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

/*
https://www.raywenderlich.com/392-uicollectionview-custom-layout-tutorial-pinterest

Note: As prepare() is called whenever the collection view's layout is invalidated, there are many situations in a typical implementation where you might need to recalculate attributes here. For example, the bounds of the UICollectionView might change - such as when the orientation changes - or items may be added or removed from the collection. These cases are out of scope for this tutorial, but it's important to be aware of them in a non-trivial implementation.
*/

protocol PinterestStyleLayoutDelegate: class {
	func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class PinterestStyleLayout: UICollectionViewLayout {

	weak var delegate: PinterestStyleLayoutDelegate!

	fileprivate var numberOfColumns = 2
	fileprivate var cellPading: CGFloat = 6

	fileprivate var cache = [UICollectionViewLayoutAttributes]()

	fileprivate var contentHeight: CGFloat = 0

	fileprivate var contentWidth: CGFloat {
		guard let collectionView = collectionView else { return 0 }
		let insets = collectionView.contentInset
		return collectionView.bounds.width - (insets.left + insets.right)
	}

	override var collectionViewContentSize: CGSize {
		return CGSize(width: contentWidth, height: contentHeight)
	}

	override func invalidateLayout() {
		super.invalidateLayout()
		cache = []
	}

	override func prepare() {
		super.prepare()
		guard
			cache.isEmpty == true,
			let collectionView = collectionView else { return }

		let columnWidth = contentWidth / CGFloat(numberOfColumns)
		var xOffset = [CGFloat]()
		for column in 0 ..< numberOfColumns {
			xOffset.append(CGFloat(column) * columnWidth)
		}

		var column = 0
		var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)

		for item in 0 ..< collectionView.numberOfItems(inSection: 0) {

			let indexPath = IndexPath(item: item, section: 0)
			let libraryItemHeight	= delegate.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)

			//			func height() -> CGFloat {
			//				let maxHeigtht: CGFloat = 300
			//				let height				= (cellPading * 1 + libraryItemHeight) // * 2 for twice height.
			//				if height > maxHeigtht {return maxHeigtht} else {return height}
			//				//				return cellPading * 2 + libraryItemHeight
			//			}

			func height() -> CGFloat {
				return cellPading + libraryItemHeight
			}

			let frame				= CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height())
			let insetFrame			= frame.insetBy(dx: cellPading, dy: cellPading)

			let attributes 			= UICollectionViewLayoutAttributes(forCellWith: indexPath)
			attributes.frame 		= insetFrame
			cache.append(attributes)

			contentHeight 			= max(contentHeight, frame.maxY)
			yOffset[column] 		= yOffset[column] + height()
			column = column < (numberOfColumns - 1) ? (column + 1) : 0
		}
	}

	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		//can be implemented with binary search
		var visibleAttributes = [UICollectionViewLayoutAttributes]()
		for attributes in cache {
			if attributes.frame.intersects(rect) {
				visibleAttributes.append(attributes)
			}
		}
		return visibleAttributes
	}
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return cache[indexPath.row]
	}
}
