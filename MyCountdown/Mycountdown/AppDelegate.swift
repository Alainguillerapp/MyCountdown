//
//  AppDelegate.swift
//  Mycountdown
//
//  Created by Danil Ovcharenko on 31.10.2025.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  static var orientationLock = UIInterfaceOrientationMask.portrait
  
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return AppDelegate.orientationLock
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    NotificationManager.shared.requestAuthorization()
    return true
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    UNUserNotificationCenter.current().setBadgeCount(0) { error in
      if let error = error {
        print("❌ Failed to reset badge:", error.localizedDescription)
      } else {
        print("✅ Badge reset to 0")
      }
    }
    
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
  }
}
