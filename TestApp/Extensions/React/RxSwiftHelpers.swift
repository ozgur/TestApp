//
//  RxSwiftHelpers.swift
//  TestApp
//
//  Created by Ozgur on 17/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import Alamofire
import RxCocoa
import RxSwift
import SwiftyBeaver

// MARK: ObservableType

extension ObservableType {
  
  @discardableResult func shared() -> Observable<Self.E> {
    return shareReplay(1)
  }
  
  @discardableResult
  func subscribe(onNext: ((Self.E) -> Swift.Void)?) -> Disposable {
    return self.subscribe(onNext: onNext, onError: nil, onCompleted: nil, onDisposed: nil)
  }
  
  @discardableResult
  func log(identifier: String? = nil) -> Observable<Self.E> {
    return Observable.create { observer in
      if let identifier = identifier {
        SwiftyBeaver.debug("Subscribed: \(identifier)")
      }
      let subscription = self.subscribe { event in
        SwiftyBeaver.debug("\(identifier ?? "Event"): \(event)")
        observer.on(event)
      }
      return Disposables.create {
        subscription.dispose()
        if let identifier = identifier {
          SwiftyBeaver.debug("Disposed: \(identifier)")
        }
      }
    }
  }
  
  @discardableResult func mapToVoid() -> Observable<Void> {
    return map { _ in }
  }
}

// MARK: ObservableType

extension ObservableType {
  
  func retry(delay interval: RxTimeInterval) -> Observable<E> {
    return retryWhen { (errors: Observable<Error>) in
      errors.flatMap { error in
        Observable<Int>.timer(interval, scheduler: MainScheduler.instance)
      }
    }
  }
}

// MARK: SharedSequenceConvertibleType

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {
  
  @discardableResult
  func drive(onNext: @escaping ((Self.E) -> Swift.Void)) -> Disposable {
    return drive(onNext: onNext, onCompleted: nil, onDisposed: nil)
  }
  
  @discardableResult func mapToVoid() -> Driver<Void> {
    return map { _ in }
  }
}

// MARK: Helpers

func castOrThrow<T>(_ resultType: T.Type, _ object: Any?) throws -> T {
  let object = object ?? NSNull()
  guard let returnValue = object as? T else {
    throw RxCocoaError.castingError(object: object, targetType: resultType)
  }
  return returnValue
}

func castOptionalOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T? {
  if NSNull().isEqual(object) {
    return nil
  }
  guard let returnValue = object as? T else {
    throw RxCocoaError.castingError(object: object, targetType: resultType)
  }
  return returnValue
}
