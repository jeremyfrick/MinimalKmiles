//
//  AppDelegate.swift
//  MinimalKmiles
//
//  Created by Jeremy Frick on 3/8/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var coreLocationController = CoreLocationController()
    lazy var coreDataStack = CoreDataStack()
    let prefs = NSUserDefaults(suiteName: "group.RedAnchorSoftware.MinimalKmiles")!
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        setupAppearance()
        let navigationController = self.window!.rootViewController as! UINavigationController
        let viewController = navigationController.topViewController as! ViewTripsControllerTableViewController
        viewController.managedContext = coreDataStack.context
        viewController.locationManager = coreLocationController
        IQKeyboardManager.sharedManager().enable = true
        self.isAppAlreadyLaunchedOnce()
        return true
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        
        if let isAppAlreadyLaunchedOnce = prefs.stringForKey("isAppAlreadyLaunchedOnce"){
            print("App already launched")
            return true
        }else{
            prefs.setBool(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            prefs.setInteger(1, forKey: "TripInProgress")
            return false
        }
    }
    
    func setupAppearance() {
        
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor(red: 91.0/255.0, green: 74.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        navigationBarAppearance.tintColor = UIColor(red: 195.0/255.0, green: 100.0/255.0, blue: 53.0/255.0, alpha: 1.0)
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor(red: 195.0/255.0, green: 100.0/255.0, blue: 53.0/255.0, alpha: 1.0)]
        
        preferredStatusBarStyle()
    }
    
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        coreDataStack.saveContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        coreDataStack.saveContext()
    }


}

