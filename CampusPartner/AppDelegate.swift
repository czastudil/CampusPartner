//
//  AppDelegate.swift
//  CampusPartner
//
//  Created by Cindy Zastudil on 1/9/20.
//  Copyright © 2020 Cindy Zastudil. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var hasAlreadyLaunched: Bool!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isFirstTime") == nil {
            defaults.set("No", forKey:"isFirstTime")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileCreation")
            self.window?.rootViewController = viewController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    func sethasAlreadyLaunched(){
        hasAlreadyLaunched = true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        for window in application.windows {
            window.rootViewController?.beginAppearanceTransition(false, animated: false)
            window.rootViewController?.endAppearanceTransition()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        for window in application.windows {
            window.rootViewController?.beginAppearanceTransition(true, animated: false)
            window.rootViewController?.endAppearanceTransition()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        for window in application.windows {
            window.rootViewController?.beginAppearanceTransition(true, animated: false)
            window.rootViewController?.endAppearanceTransition()
        }
    }

}

