//
//  NSObject+Rx.swift
//  TestApp
//
//  Created by Ozgur on 15/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import Foundation
import ObjectiveC
import RxCocoa
import RxSwift
import SwiftyUserDefaults
import UIKit

extension NSObject {
  fileprivate struct AssociatedKeys {
    static var DisposeBag = "rx_disposeBag"
  }
  
  fileprivate func doLocked(_ closure: () -> Void) {
    objc_sync_enter(self); defer { objc_sync_exit(self) }
    closure()
  }
  
  var rx_disposeBag: DisposeBag {
    get {
      var disposeBag: DisposeBag!
      doLocked {
        let lookup = objc_getAssociatedObject(self, &AssociatedKeys.DisposeBag) as? DisposeBag
        if let lookup = lookup {
          disposeBag = lookup
        } else {
          let newDisposeBag = DisposeBag()
          self.rx_disposeBag = newDisposeBag
          disposeBag = newDisposeBag
        }
      }
      return disposeBag
    }
    
    set {
      doLocked {
        objc_setAssociatedObject(self, &AssociatedKeys.DisposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }
}

extension Reactive where Base: NSObject {
  
  var disposeBag: DisposeBag {
    return base.rx_disposeBag
  }
}

extension Reactive where Base: NSObject {
  
  /// A binding observer that logs the given string.
  var log: UIBindingObserver<Base, CustomStringConvertible> {
    return UIBindingObserver(UIElement: base) { object, log in
      object.logger.debug(log.description)
    }
  }
  
  /// A binding observer responsible that logs the given error.
  var error: UIBindingObserver<Base, NSError> {
    return UIBindingObserver(UIElement: base) { object, error in
      object.logger.error(error.localizedDescription)
    }
  }

  /// A binding observer responsible for setting application's badge count.
  var badgeCount: UIBindingObserver<Base, Int> {
    return UIBindingObserver(UIElement: base) { object, count in
      UIApplication.shared.applicationIconBadgeNumber = count
      object.logger.debug("Set badge count to \(count)")
    }
  }
  
  /// A binding observer responsible for reseting application's badge count.
  var resetBadgeCount: UIBindingObserver<Base, Void> {
    return UIBindingObserver(UIElement: base) { object, count in
      if UIApplication.shared.applicationIconBadgeNumber != 0 {
        UIApplication.shared.applicationIconBadgeNumber = 0
        object.logger.debug("Set badge count to 0")
      }
    }
  }
  
  /**
   A binding observer that tries to register for remote notifications 
   only if user grants permission.
   
   It sets `wasRemoteNotificationPermissionRequested` value in user defaults.
  */
  var registerForRemoteNotifications: UIBindingObserver<Base, Void> {
    return UIBindingObserver(UIElement: base) { object, void in
      
      Dependencies.shared.notificationService.getAuthorizationSettings {
        settings in
        if settings.authorizationStatus == .authorized {
          UIApplication.shared.registerForRemoteNotifications()
          object.logger.debug("Registered for remote notifications (2)")
        }
      }
      Defaults[.wasRemoteNotificationPermissionRequested] = true
    }
  }
  
  /**
   A binding observer that sets `NotificationService.shared.apns` 
   to current `PushDevice` instance and logs it.
  */
  var apns: UIBindingObserver<Base, PushDevice> {
    return UIBindingObserver(UIElement: base) { object, apns in
      Dependencies.shared.notificationService.apns = apns
      object.logger.debug("Saved device: \(apns)")
    }
  }
  
  /// A binding observer to start/stop CoreLocation services.
  var toggleGPS: UIBindingObserver<Base, Bool> {
    return UIBindingObserver(UIElement: base) { object, authorized in
      if authorized {
        Dependencies.shared.locationService.start()
        object.logger.debug("Started location services")
      } else {
        Dependencies.shared.locationService.stop()
        object.logger.debug("Stopped location services")
      }
    }
  }
}

