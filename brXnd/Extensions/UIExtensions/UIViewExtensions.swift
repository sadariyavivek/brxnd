//
//  UIViewExtensions.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-04-05.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//
extension UIView {

	@IBInspectable var cornerRadius: CGFloat {
		get {
			return self.layer.cornerRadius
		}
		set {
			self.layer.cornerRadius = newValue
		}
	}

	@IBInspectable var borderColor: UIColor? {
		get {
			if let color = self.layer.borderColor {
				return UIColor(cgColor: color)
			}
			return nil
		}
		set {
			self.layer.borderColor = newValue?.cgColor
		}
	}

	@IBInspectable var borderWidth: CGFloat {
		get {
			return self.layer.borderWidth
		}
		set {
			self.layer.borderWidth = newValue
		}
	}
}

extension UIView {
	static func wrapView(padding: UIEdgeInsets) -> (UIView) -> UIView {
		return { subview in
			let wrapper = UIView()
			subview.translatesAutoresizingMaskIntoConstraints = false
			wrapper.addSubview(subview)
			NSLayoutConstraint.activate([
				subview.leadingAnchor.constraint(
					equalTo: wrapper.leadingAnchor, constant: padding.left
				),
				subview.rightAnchor.constraint(
					equalTo: wrapper.rightAnchor, constant: -padding.right
				),
				subview.topAnchor.constraint(
					equalTo: wrapper.topAnchor, constant: padding.top
				),
				subview.bottomAnchor.constraint(
					equalTo: wrapper.bottomAnchor, constant: -padding.bottom
				)
				])
			return wrapper
		}
	}
}

extension UIView {
	func addShadow(to edges: [UIRectEdge], radius: CGFloat = 3.0, opacity: Float = 0.6, color: CGColor = UIColor.black.cgColor) {
		let fromColor = color
		let toColor = UIColor.clear.cgColor
		let viewFrame = self.frame
		for edge in edges {
			let gradientLayer = CAGradientLayer()
			gradientLayer.colors = [fromColor, toColor]
			gradientLayer.opacity = opacity

			switch edge {
			case .top:
				gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
				gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
				gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: viewFrame.width, height: radius)
			case .bottom:
				gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
				gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
				gradientLayer.frame = CGRect(x: 0.0, y: viewFrame.height - radius, width: viewFrame.width, height: radius)
			case .left:
				gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
				gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
				gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: radius, height: viewFrame.height)
			case .right:
				gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
				gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
				gradientLayer.frame = CGRect(x: viewFrame.width - radius, y: 0.0, width: radius, height: viewFrame.height)
			default:
				break
			}
			self.layer.addSublayer(gradientLayer)
		}
	}

	func removeAllShadows() {
		if let sublayers = self.layer.sublayers, !sublayers.isEmpty {
			for sublayer in sublayers {
				sublayer.removeFromSuperlayer()
			}
		}
	}
}

extension UIView {
	func asImage() -> UIImage {
		let renderer = UIGraphicsImageRenderer(bounds: bounds)
		return renderer.image { rendererContext in
			layer.render(in: rendererContext.cgContext)
		}
	}
}

extension UIView {
	var horizontalScale: CGFloat {
		return pow(
			pow(transform.a, 2) + pow(transform.c, 2),
			0.5
		)
	}

	var verticalScale: CGFloat {
		return pow(
			pow(transform.b, 2) + pow(transform.d, 2),
			0.5
		)
	}
}

extension UIView: NSCopying {
	public func copy(with zone: NSZone? = nil) -> Any {
		let copy = UIView(frame: self.frame)
		copy.backgroundColor = self.backgroundColor
		return copy
	}
}

/*
let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
view.backgroundColor = .darkGray

let padding = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)

let wrapper = wrapView(padding: padding)(view)
wrapper.frame.size = CGSize(width: 300, height: 300)
wrapper.backgroundColor = .lightGray
wrapper

wrapView(padding: padding) as (UIView) -> UIView
wrapView(padding: padding) as (UIButton) -> UIView
wrapView(padding: padding) as (UISwitch) -> UIView
wrapView(padding: padding) as (UIStackView) -> UIView


//wrapView(padding: padding) as (UIView) -> UIButton
wrapView(padding: padding) as (UIView) -> UIResponder
wrapView(padding: padding) as (UIView) -> NSObject
wrapView(padding: padding) as (UIView) -> AnyObject
*/
