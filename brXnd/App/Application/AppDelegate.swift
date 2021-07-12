//
//  AppDelegate.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-01-25.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Firebase
import FBSDKCoreKit
import PhotoEditorSDK
import IQKeyboardManagerSwift
import UserNotifications

enum Identifiers {
  static let viewAction = "VIEW_IDENTIFIER"
  static let newsCategory = "NEWS_CATEGORY"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
    var deviceTocken:String = String()
	private lazy var applicationCoordinator: Coordinator = makeCoordinator()
	
	var rootController: UINavigationController {
		let navController = window!.rootViewController as! UINavigationController
		return navController
	}
    
	
	private func makeCoordinator() -> Coordinator {
		return ApplicationCoordinator(coordinatorFactory: CoordinatorFactoryImp(),
									  router: RouterImp(rootController: self.rootController))
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
       
        
////		#if DEBUG
////		print("🎴 Current user: \(String(describing: Current.user))")
////		_ = Observable<Int>.interval(.seconds(10), scheduler: MainScheduler.instance)
////			.subscribe(onNext: { _ in
////				print("Resource count \(RxSwift.Resources.total)")
////			})
////		#else
////		//		AuthHelper.removeCurrentUser()
////		#endif
//		//FacebookSDK
//
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//
//        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
//
//        let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
//
//        self.window?.rootViewController = initialViewController
//        self.window?.makeKeyAndVisible()
//
//		ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
//
//		/* lib used to fix overalpping uitextfields and many more such issues. */
//		IQKeyboardManager.shared.enable = true
//		guard
//			let licenseURL = Bundle.main.url(forResource: "license", withExtension: "dms") else { fatalError("[Photo SDK] Can't retrieve PhotoEditorSDK license ") }
//		PESDK.unlockWithLicense(at: licenseURL)
//		FirebaseApp.configure()
//		StoreKitHelper.incrementNumberOfTimesLaunched()
//		//applicationCoordinator.start()
//		return true
        
        #if DEBUG
        print("🎴 Current user: \(String(describing: Current.user))")
        _ = Observable<Int>.interval(.seconds(10), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                print("Resource count \(RxSwift.Resources.total)")
            })
        #else
        //        AuthHelper.removeCurrentUser()
        #endif
        //FacebookSDK
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        /* lib used to fix overalpping uitextfields and many more such issues. */
        IQKeyboardManager.shared.enable = true
        guard
            let licenseURL = Bundle.main.url(forResource: "license", withExtension: "dms") else { fatalError("[Photo SDK] Can't retrieve PhotoEditorSDK license ") }
        PESDK.unlockWithLicense(at: licenseURL)
        FirebaseApp.configure()
        StoreKitHelper.incrementNumberOfTimesLaunched()
        applicationCoordinator.start()
        registerForPushNotifications()
        
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]
        
//        // 1
//        if let notification = notificationOption as? [String: AnyObject],
//          let aps = notification["aps"] as? [String: AnyObject] {
//
//          // 2
//          _ = NewsItem.makeNewsItem(aps)
//
//          // 3
//          (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
//        }
        return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	// MARK: - Facebook SDK callback
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		return ApplicationDelegate.shared.application(app, open: url, options: options)
	}
    
     func registerForPushNotifications() {
       UNUserNotificationCenter.current()
         .requestAuthorization(options: [.alert, .sound, .badge]) {
           [weak self] granted, error in
           guard let self = self else { return }
           print("Permission granted: \(granted)")
           
           guard granted else { return }
           
           // 1
           let viewAction = UNNotificationAction(
             identifier: Identifiers.viewAction, title: "View",
             options: [.foreground])
           
           // 2
           let newsCategory = UNNotificationCategory(
             identifier: Identifiers.newsCategory, actions: [viewAction],
             intentIdentifiers: [], options: [])
           
           // 3
           UNUserNotificationCenter.current()
             .setNotificationCategories([newsCategory])
           
           self.getNotificationSettings()
       }
     }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        deviceTocken = token
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    

}
