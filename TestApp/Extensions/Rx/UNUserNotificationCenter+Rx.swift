//
//  UNUserNotificationCenter+Rx.swift
//  TestApp
//
//  Created by Ozgur on 30/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import RxCocoa
import RxSwift
import UserNotifications

// MARK: UNUserNotificationCenterDelegateProxy

class UNUserNotificationCenterDelegateProxy: DelegateProxy, UNUserNotificationCenterDelegate, DelegateProxyType {

  class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
    let notificationCenter: UNUserNotificationCenter = object as! UNUserNotificationCenter
    return notificationCenter.delegate
  }

  class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
    let notificationCenter: UNUserNotificationCenter = object as! UNUserNotificationCenter
    notificationCenter.delegate = delegate as? UNUserNotificationCenterDelegate
  }
}

// MARK: UNUserNotificationCenter

extension Reactive where Base: UNUserNotificationCenter {
  
  var delegate: DelegateProxy {
    return UNUserNotificationCenterDelegateProxy.proxyForObject(base)
  }
}
