extension NSObject {

	class var className: String {
		guard let name = NSStringFromClass(self).components(separatedBy: ".").last else { fatalError("Accessed wrong defined name of a class")}
		return name
	}
}
