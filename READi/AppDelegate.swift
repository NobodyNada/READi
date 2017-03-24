//
//  AppDelegate.swift
//  READY
//
//  Created by NobodyNada on 3/21/17.
//  Copyright © 2017 NobodyNada. All rights reserved.
//

import UIKit

enum Feedback {
	case spam
	case vandalism
	case naa
	case fp
	
	var color: UIColor {
		switch self {
		case .spam, .vandalism:
			return #colorLiteral(red: 0.2352941176, green: 0.462745098, blue: 0.2392156863, alpha: 1)
		case .naa:
			return #colorLiteral(red: 0.5098039216, green: 0.3254901961, blue: 0.1450980392, alpha: 1)
		case .fp:
			return #colorLiteral(red: 0.662745098, green: 0.2666666667, blue: 0.2588235294, alpha: 1)
		}
	}
	
	var identifier: String {
		switch self {
		case .spam:
			return "tpu-"
		case .vandalism:
			return "tp-"
		case .naa:
			return "naa-"
		case .fp:
			return "fp-"
		}
	}
}

extension UIViewController {
	func alert(_ message: String, details: String? = nil) {
		let alertController = UIAlertController(title: message, message: details, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alertController, animated: true)
	}
}


let client = Client(key: "825951bc05e37a875a13b95855c6e2a485637ce645513507e9b063dbb405715b")

let metasmokeFilter = "%00%00%00%00%C2%BF%C2%88%00%03%C3%BF%C3%BF%C2%80%07%C3%80%00%01%C3%B9"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
	var application: UIApplication!
	
	var window: UIWindow?
	
	func getWriteToken(_ completion: @escaping (String?) -> Void) {
		DispatchQueue.main.async {
			if let token = UserDefaults.standard.string(forKey: "write_token") {
				completion(token)
			} else {
				let rootVC = self.window?.rootViewController as? RootViewController
				rootVC?.performSegue(withIdentifier: "Authenticate", sender: self)
				
				rootVC?.authenticationCompletions.append(completion)
				rootVC?.authenticationCompletions.append {token in
					if token == nil { return }
					UserDefaults.standard.set(token, forKey: "write_token")
				}
				
			}
		}
	}
	
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		self.application = application
		
		return true
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		let splitViewController = self.window!.rootViewController as! UISplitViewController
		let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
		navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
		splitViewController.delegate = self
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
	
	// MARK: - Split view
	
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
		guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
		guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
		if topAsDetailController.post == nil {
			// Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
			return true
		}
		return false
	}
	
}

