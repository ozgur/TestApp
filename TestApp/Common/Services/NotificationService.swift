//
//  NotificationService.swift
//  TestApp
//
//  Created by Ozgur on 30/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import RxCocoa
import RxSwift
import RxOptional
import UserNotifications

final class NotificationService: NSObject, UNUserNotificationCenterDelegate  {
  
  static let shared = NotificationService()
  
  var apns: PushDevice = PushDevice.invalid
  
  private let authorizationStatus: BehaviorSubject<UNAuthorizationStatus>
  
  var authorization: Driver<UNAuthorizationStatus> {
    return authorizationStatus.asDriver(onErrorJustReturn: .notDetermined)
  }
  
  var authorizationGranted: Driver<Void> {
    return authorization.filter { $0 == .authorized }.mapToVoid()
  }
  
  var authorizationDenied: Driver<Void> {
    return authorization.filter { $0 == .denied }.mapToVoid()
  }
  
  override init() {
    authorizationStatus = BehaviorSubject(value: .notDetermined)
    super.init()
  }
  
  func getAuthorizationSettings(_ completion: @escaping ((UNNotificationSettings) -> Void)) {
    UNUserNotificationCenter.current().getNotificationSettings {
      settings in
      // Sometimes this block may be called by a background thread
      // so we have to relay to main thread whatsoever.
      DispatchQueue.main.async { completion(settings) }
    }
  }
  
  func checkAuthorization() {
    self.getAuthorizationSettings { [unowned self] settings in
      self.authorizationStatus.onNext(settings.authorizationStatus)
    }
  }
  
  deinit {
    authorizationStatus.onCompleted()
  }
}
