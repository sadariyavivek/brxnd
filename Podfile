# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

inhibit_all_warnings!

def sharedPods
	use_frameworks!
	# firebase
	pod 'Firebase/Core'
	pod 'Fabric'
	pod 'Crashlytics'
	pod 'Firebase/Performance'
	pod 'Firebase/Analytics'
	pod 'Firebase/Messaging'
	# rx
	pod 'Action'
	pod 'RxSwift'
	pod 'RxCocoa'
	pod 'RxSwiftExt'
	pod 'RxFeedback'
  pod 'RxGesture'
	pod 'RxDataSources'
	#pod 'NSObject+Rx'
	# photo editor, images
	pod 'Nuke'
	pod 'RxNuke'
	pod 'PhotoEditorSDK'
	pod 'UIImageColors'
	# utils
	pod 'Device'
	pod 'Former'
	pod 'SwiftKeychainWrapper'
	pod 'IQKeyboardManagerSwift'
	# pod 'SwifterSwift'
	# facebook login
	pod 'FBSDKCoreKit/Swift'
	pod 'FBSDKLoginKit/Swift'
	pod 'FBSDKShareKit/Swift'
	# UI
	pod 'EmptyStateKit'
	pod 'NVActivityIndicatorView'
	#pod 'Hero'
	pod 'FlexColorPicker'
end

target 'brXnd Dev' do
	# Pods for brXnd
	use_frameworks!
	sharedPods
	pod 'SwiftLint'
end

target 'brXnd Prod' do
	# Pods for brXnd
	use_frameworks!
	sharedPods
end

post_install do |installer|
   installer.pods_project.targets.each do |target|
      if target.name == 'RxSwift'
         target.build_configurations.each do |config|
            if config.name == 'Debug'
               config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
            end
         end
      end
   end
end
