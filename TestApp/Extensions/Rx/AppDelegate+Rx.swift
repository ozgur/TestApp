//
//  AppDelegate+Rx.swift
//  TestApp
//
//  Created by Ozgur on 19/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import RxCocoa
import RxSwift
import RxSwiftExt
import UIKit

// MARK: RxApplicationState

enum RxApplicationState: Equatable {
  case active
  case inactive
  case background
  case terminating
}

func ==(lhs: RxApplicationState, rhs: RxApplicationState) -> Bool {
  switch (lhs, rhs) {
  case (.active, .active),
       (.inactive, .inactive),
       (.background, .background),
       (.terminating, .terminating):
    return true
  default:
    return false
  }
}

// MARK: AppDelegate

extension Reactive where Base: AppDelegate {
  
  var applicationState: Observable<RxApplicationState> {
    return Observable.of(
      applicationDidBecomeActive,
      applicationWillResignActive,
      applicationDidEnterBackground,
      applicationWillTerminate
      )
      .merge()
  }
  
  var applicationDidOpen: Observable<Void> {
    return Observable.of(
      applicationDidBecomeActive,
      applicationDidEnterBackground
      )
      .merge()
      .distinctUntilChanged()
      .filter { $0 == .active }
      .mapToVoid()
  }
  
  var applicationDidBecomeActive: Observable<RxApplicationState> {
    return methodInvoked(#selector(AppDelegate.applicationDidBecomeActive(_:)))
      .mapTo(RxApplicationState.active)
  }
  
  var applicationWillResignActive: Observable<RxApplicationState> {
    return methodInvoked(#selector(AppDelegate.applicationWillResignActive(_:)))
      .mapTo(RxApplicationState.inactive)
  }
  
  var applicationDidEnterBackground: Observable<RxApplicationState> {
    return methodInvoked(#selector(AppDelegate.applicationDidEnterBackground(_:)))
      .mapTo(RxApplicationState.background)
  }
  
  var applicationWillTerminate: Observable<RxApplicationState> {
    return methodInvoked(#selector(AppDelegate.applicationWillTerminate(_:)))
      .mapTo(RxApplicationState.terminating)
  }
  
  var applicationDidRegisterUserNotificationSettings: Observable<UIUserNotificationSettings> {
    return methodInvoked(#selector(AppDelegate.application(_:didRegister:)))
      .map { args in
        return try castOrThrow(UIUserNotificationSettings.self, args[1])
    }
  }
  
  var applicationDidRegisterForRemoteNotificationsWithDeviceToken: Observable<String> {
    return methodInvoked(#selector(AppDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)))
      .map { args in
        return try castOrThrow(Data.self, args[1]).deviceToken
    }
  }
  
  var applicationDidFailToRegisterForRemoteNotificationsWithError: Observable<NSError> {
    return methodInvoked(#selector(AppDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:)))
      .map { args in
        return try castOrThrow(NSError.self, args[1])
    }
  }
}
