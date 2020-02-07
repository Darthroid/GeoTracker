//
//  AppDelegate.swift
//  getlocation
//
//  Created by Олег Комаристый on 23.03.17.
//  Copyright © 2017 Darthroid. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CoreDataManager.shared.initalizeStack(completion: {})
        
        if let splitViewController = self.window?.rootViewController as? UISplitViewController {
            splitViewController.preferredDisplayMode = .allVisible
            if let navigationController = splitViewController.viewControllers.last as? UINavigationController {
                navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            }
        }
		
        return true
    }
	
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		let fileName = (url.lastPathComponent as NSString).deletingPathExtension
		let ac = UIAlertController(title: "Import \(fileName) ?", message: "", preferredStyle: .alert)
		
		let importAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
			do {
				try GPXParseManager.parseGPX(fromUrl: url, save: true)
			} catch {
				AlertManager.showError(title: ERROR_TITLE, message: error.localizedDescription)
			}
		})
		
		let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
		
		ac.addAction(importAction)
		ac.addAction(cancelAction)
		
		CommonUtils.visibleViewController?.present(ac, animated: true)
		
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
        // Saves changes in the application's managed object context before the application terminates.
    }
    
}

