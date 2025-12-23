//
//  AppDelegate.swift
//  Cosmofy
//
//  Created for iOS 9+ compatibility
//

import UIKit
#if swift(>=5.9)
import SwiftUI
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)

        #if swift(>=5.9)
        if #available(iOS 17.0, *) {
            // iOS 17+ gets SwiftUI
            window?.rootViewController = UIHostingController(rootView: SplashScreen())
        } else {
            // iOS 9-16 gets programmatic UIKit tab bar
            window?.rootViewController = LegacyTabBarController()
        }
        #else
        // Fallback for older Swift
        window?.rootViewController = LegacyTabBarController()
        #endif

        window?.makeKeyAndVisible()
        return true
    }
}
