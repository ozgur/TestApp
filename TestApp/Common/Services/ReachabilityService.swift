//
//  ReachabilityService.swift
//  TestApp
//
//  Created by Ozgur on 17/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import Reachability
import RxSwift

// MARK: ReachabilityStatus

enum ReachabilityStatus {
  case reachable(viaWiFi: Bool)
  case unreachable
  
  var reachable: Bool {
    switch self {
    case .reachable:
      return true
    case .unreachable:
      return false
    }
  }
  
  var unreachable: Bool {
    return !reachable
  }
}

// MARK: ReachabilityError

extension ReachabilityError {
  static let failedToCreate = ReachabilityError.FailedToCreateWithHostname("")
}

// MARK: ReachabilityService

final class ReachabilityService {
  
  static let shared = try? ReachabilityService()
  
  var reachability: Observable<ReachabilityStatus> {
    return _reachabilityStatus.asObservable()
  }
  
  var reachabilityReachable: Observable<Void> {
    return reachability.filter { $0.reachable }.mapToVoid()
  }
  
  var reachabilityUnreachable: Observable<Void> {
    return reachability.filter { !$0.reachable }.mapToVoid()
  }
  
  var isReachable: Bool {
    return _reachability.isReachable
  }
  
  private let _reachabilityStatus: BehaviorSubject<ReachabilityStatus>
  private let _reachability: Reachability
  
  init() throws {
    guard let _reachability = Reachability() else {
      throw ReachabilityError.failedToCreate
    }
    let _reachabilityStatus = BehaviorSubject<ReachabilityStatus>(
      value: .unreachable
    )
    let backgroundQueue = DispatchQueue(label: "reachability.wificheck")
    
    _reachability.whenReachable = { reachability in
      backgroundQueue.async {
        _reachabilityStatus.on(
          .next(.reachable(viaWiFi: reachability.isReachableViaWiFi))
        )
      }
    }
    _reachability.whenUnreachable = { reachability in
      backgroundQueue.async {
        _reachabilityStatus.on(.next(.unreachable))
      }
    }
    self._reachability = _reachability
    self._reachabilityStatus = _reachabilityStatus
    
    try self._reachability.startNotifier()
  }
  
  deinit {
    _reachability.stopNotifier()
  }
}

// MARK: Retrying until network is reachable

extension ObservableConvertibleType {
  
  func retryWhenReachable(_ unreachableValue: E, service: ReachabilityService?,
                          delay: RxTimeInterval = 3.0)
    -> Observable<E> {
      guard let service = service else { return asObservable() }
      
      return asObservable().catchError({ error -> Observable<E> in
        service.reachability
          .filter({ $0.reachable })
          .flatMap({ _ in Observable<E>.error(error) })
          .startWith(unreachableValue)
      })
        .retry(delay: delay)
  }
}
