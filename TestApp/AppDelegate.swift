//
//  AppDelegate.swift
//  TestApp
//
//  Created by Ozgur on 28/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import CoreLocation
import Device
import RxSwift
import SwiftyUserDefaults
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
  var window: UIWindow?
  
  func application(_ application: UIApplication, willFinishLaunchingWithOptions
    launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    
    Defaults[.distanceFilter] = 20000 // TODO: This will be specified by user later on.
    
    configure()
    return true
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    // Since we can't know in `applicationDidBecomeActive` whether app 
    // comes from background or is launched from start, we are holding 
    // a value named `wasRemoteNotificationPermissionRequested` in defaults
    // in order to differentiate those two launch states.
    
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
    
    // Reset badge count whenever application becomes active.
    rx.applicationDidBecomeActive
      .mapToVoid()
      .bindTo(rx.resetBadgeCount)
      .addDisposableTo(rx.disposeBag)
    
    
    // User granted permissions for notifications so we'll go register
    // for receiving remote notifications.
    rx.applicationDidRegisterUserNotificationSettings
      // TODO: We'll come to this later!
      .filter { $0.types == [.alert, .sound, .badge] }
      .mapToVoid()
      .bindTo(rx.registerForRemoteNotifications)
      .addDisposableTo(rx.disposeBag)
    
    
    // Request to register for remote notifications if you haven't done
    // that already.
    Dependencies.shared.notificationService.authorizationGranted
      .asObservable()
      .ignoreWhen {
        Defaults.hasKey(.wasRemoteNotificationPermissionRequested)
      }
      .bindTo(rx.registerForRemoteNotifications)
      .addDisposableTo(rx.disposeBag)
    
    
    // We registered for remote notifications and device token is 
    // obtained so, we go tell API to register the token.
    rx.applicationDidRegisterForRemoteNotificationsWithDeviceToken
      .do(onNext: { token in
        // Save it in defaults for later use.
        Defaults[.token] = token
      })
      .flatMap { token in
        API.shared.registerDevice(token: token)
          .retryWhenReachable(.invalid, service: .shared)
      }
      .ignoreWhen { device in
        device == .invalid
      }
      .bindTo(rx.apns)
      .addDisposableTo(rx.disposeBag)

    
    // User rejected to give permission to register for remote 
    // notifications so, we unregister device token from backend.
    Dependencies.shared.notificationService.authorizationDenied
      .do(onNext: {
        Defaults.remove(.wasRemoteNotificationPermissionRequested)
      })
      .asObservable()
      .flatMap {
        API.shared.unregisterDevice()
      }
      .map { PushDevice.invalid }
      .bindTo(rx.apns)
      .addDisposableTo(rx.disposeBag)


    // Registering for push notification has failed. (Network outage...)
    rx.applicationDidFailToRegisterForRemoteNotificationsWithError
      .bindTo(rx.error)
      .addDisposableTo(rx.disposeBag)

    
    // Unlike CoreLocation, iOS does not inform users of changes in
    // remote notification settings automatically so we have to do it manually.
    rx.applicationDidBecomeActive
      .delay(0.5, scheduler: Dependencies.shared.mainScheduler)
      .mapToVoid()
      .subscribe(onNext: {
        Dependencies.shared.notificationService.notifyObserversOfAuthorizationStatus()
      })
      .addDisposableTo(rx.disposeBag)
    
    
    // Toggle GPS services when authorization status changes.
    Dependencies.shared.locationService.authorization
      .drive(rx.toggleGPS)
      .addDisposableTo(rx.disposeBag)
    
    
    // Save user's latest location in defaults for later use.
    Dependencies.shared.locationService.location
      .drive { location in
        Defaults[.location] = location
      }
      .addDisposableTo(rx.disposeBag)
    
    
    // Log it when something bad happens in the GPS service.
    Dependencies.shared.locationService.error
      .bindTo(rx.error)
      .addDisposableTo(rx.disposeBag)
  }
}

extension AppDelegate {
  
  // We need these stub methods to make AppDelegate+Rx work as expected.
  
  func applicationWillResignActive(_ application: UIApplication) {}
  
  func applicationDidEnterBackground(_ application: UIApplication) {}
  
  func applicationDidBecomeActive(_ application: UIApplication) {}
  
  func applicationWillTerminate(_ application: UIApplication) {}
  
  func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {}
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {}
}
