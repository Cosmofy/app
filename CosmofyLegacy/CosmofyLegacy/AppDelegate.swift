//
//  AppDelegate.swift
//  CosmofyLegacy
//
//  iOS 9+ Legacy UIKit App
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = LegacyTabBarController()
        window?.makeKeyAndVisible()
        return true
    }
}
