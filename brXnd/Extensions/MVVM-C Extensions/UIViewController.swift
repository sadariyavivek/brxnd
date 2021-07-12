extension UIViewController {

	private class func instantiateControllerInStoryboard<T: UIViewController>(_ storyboard: UIStoryboard, identifier: String) -> T {
        guard let controllerInStoryboard = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            print("...\(identifier)")
			fatalError("No storyboard with name..... \(identifier)")
		}
		return controllerInStoryboard
	}
    
	class func controllerInStoryboard(_ storyboard: UIStoryboard, identifier: String) -> Self {
        print("1...")
		return instantiateControllerInStoryboard(storyboard, identifier: identifier)
	}

	class func controllerInStoryboard(_ storyboard: UIStoryboard) -> Self {
        print("2...")
		return controllerInStoryboard(storyboard, identifier: className)
	}

	class func controllerFromStoryboard(_ storyboard: Storyboards) -> Self {
        print("3...\(storyboard.rawValue)")
        
        return controllerInStoryboard(UIStoryboard(name: storyboard.rawValue, bundle: nil))
       // return controllerInStoryboard(UIStoryboard(name: storyboard.rawValue, bundle: nil), identifier: className)
        
	}
}
