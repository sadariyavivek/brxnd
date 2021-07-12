#if os(iOS)

import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: UIImagePickerController {

	/**
	Reactive wrapper for `delegate` message.
	*/
	public var didFinishPickingMediaWithInfo: Observable<[String: AnyObject]> {
		return delegate
			.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
			.map({ (res) in
				return try castOrThrow(Dictionary<String, AnyObject>.self, res[1])
			})
	}

	/**
	Reactive wrapper for `delegate` message.
	*/
	public var didCancel: Observable<()> {
		return delegate
			.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
			.map {_ in () }
	}

}

#endif

private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
	guard let returnValue = object as? T else {
		throw RxCocoaError.castingError(object: object, targetType: resultType)
	}

	return returnValue
}
