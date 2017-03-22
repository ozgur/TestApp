//
//  Dependencies.swift
//  TestApp
//
//  Created by Ozgur on 09/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import NVActivityIndicatorView
import RxSwift

// Just to remember on what I am dependent.

class Dependencies {

  static let shared = Dependencies()

  // Schedulers

  let backgroundWorkScheduler: ImmediateSchedulerType
  let serialWorkScheduler: SerialDispatchQueueScheduler
  let mainScheduler: SerialDispatchQueueScheduler

  // Services
  
  let permissionService: PermissionService
  let reachabilityService: ReachabilityService?
  let locationService: GeolocationService
  let notificationService: NotificationService

  // UI Related
  
  let activity: NVActivityIndicatorPresenter
  let wireframe: Wireframe
  
  private init() {
    
    let operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 2
    operationQueue.qualityOfService = .userInitiated
    backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
    
    mainScheduler = MainScheduler.instance
    serialWorkScheduler = SerialDispatchQueueScheduler(qos: .background)

    reachabilityService = ReachabilityService.shared
    permissionService = PermissionService.shared
    locationService = GeolocationService.shared
    notificationService = NotificationService.shared
    
    activity = NVActivityIndicatorPresenter.sharedInstance
    wireframe = Wireframe.shared
  }
}
