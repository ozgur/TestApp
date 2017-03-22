//
//  AppDelegate.swift
//  TestApp
//
//  Created by Ozgur on 28/12/2016.
//  Copyright © 2016 Ozgur. All rights reserved.
//

import AlamofireNetworkActivityIndicator
import CoreLocation
import Device
import RxSwift
import SwiftyBeaver
import SwiftyUserDefaults
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
  var window: UIWindow?
  
  // MARK: Helpers
  
  private func configureNetworkActivityIndicator() {
    NetworkActivityIndicatorManager.shared.isEnabled = true
    NetworkActivityIndicatorManager.shared.startDelay = 1.0
    NetworkActivityIndicatorManager.shared.completionDelay = 0.5
  }
  
  private func configureLogger() {
    let console = ConsoleDestination()
    console.format = "$Dyyyy/MM/dd HH:mm:ss.SSS$d $C$N.$F$c:$l $L: $M"
    console.asynchronously = true // TODO: true for production
    logger.addDestination(console)
  }
  
  func application(_ application: UIApplication, willFinishLaunchingWithOptions
    launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    
    Defaults[.distanceFilter] = 15000 // TODO: This will be specified by user later on.
    
    UILabel.appearance().textColor = R.blackTextColor
    UILabel.appearance().font = R.defaultFont(ofSize: 15)
    
    configureLogger()
    configureNetworkActivityIndicator()
    return true
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    Dependencies.shared.notificationService.getAuthorizationSettings {
      settings in
      if settings.authorizationStatus == .authorized {
        application.registerForRemoteNotifications()
        application.logger.debug("Registered for remote notifications (1)")
      }
    }
    Defaults[.wasRemoteNotificationPermissionRequested] = true
    
    setupRx()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = LaunchViewController()
    window?.makeKeyAndVisible()
    
    return true
  }
  
  private func setupRx() {

  }
}

extension AppDelegate {
  
  // We need these stub methods to make AppDelegate+Rx correctly relay UIApplication related messages.
  
  func applicationWillResignActive(_ application: UIApplication) {}
  
  func applicationDidEnterBackground(_ application: UIApplication) {}
  
  func applicationDidBecomeActive(_ application: UIApplication) {}
  
  func applicationWillTerminate(_ application: UIApplication) {}
  
  func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {}
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {}
}
