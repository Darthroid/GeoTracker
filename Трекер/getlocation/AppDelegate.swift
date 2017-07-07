//
//  AppDelegate.swift
//  getlocation
//
//  Created by Олег Комаристый on 23.03.17.
//  Copyright © 2017 Darthroid. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    var vc: ViewController?
    var window: UIWindow?
    var manager = CLLocationManager()
    var timer: Timer?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
//        manager.allowsBackgroundLocationUpdates = true
//        let timer = Timer(timeInterval: 5, repeats: true) { (timer) in
//            
//        }
        //        timer.fire()
        return true
    }
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
//        if let location = locations.first {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "HH:MM:SS"
//            print("Found user's location: \(formatter.string(from: location.timestamp))")
//            let lat = location.coordinate.latitude
//            let lon = location.coordinate.longitude
//            //vc?.sendData(lat: lat, lon: lon)
        
//
//        }
        //backgoundTask()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        //manager.startUpdatingLocation()
//        backgoundTask()
        //manager.delegate = self
//        vc?.foregroundManager.stopUpdatingLocation()
//        if vc?.refreshFlag == true{
//            manager.startUpdatingLocation()
//            var refreshRate = vc?.refreshRatevalue
//            timer = Timer.scheduledTimer(withTimeInterval: refreshRate!, repeats: true) { (timer) in
//                let latitude = self.manager.location?.coordinate.latitude
//                let longitude = self.manager.location?.coordinate.longitude
//                self.vc?.sendData(lat: latitude!, lon: longitude!)
//                print(latitude as Any,longitude as Any)
//                refreshRate = self.vc?.refreshRatevalue
//            }
//        } else if vc?.refreshFlag == false{
//            manager.stopUpdatingLocation()
//            timer?.invalidate()
//
//        }

        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        //manager.stopUpdatingLocation()
//        timer?.invalidate()
//        vc?.foregroundManager.startUpdatingLocation()
//        if vc?.refreshFlag == false{
//            vc?.additionalInfo.text = ""
//        } else if vc?.refreshFlag == true{
//            vc?.additionalInfo.text = "Terminating background updates.\n\nTip: Pick new refresh time and press Start button to start updating again"
//        }
//        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "getlocation")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

