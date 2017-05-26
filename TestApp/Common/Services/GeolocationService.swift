//
//  GeolocationService.swift
//  TestApp
//
//  Created by Ozgur on 18/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import MapKit
import RxCocoa
import RxSwift
import SwiftyUserDefaults

final class GeolocationService: NSObject {
  
  static let shared = GeolocationService()
  static let desiredAuthorizationStatus: CLAuthorizationStatus = .authorizedAlways
  
  private(set) var authorization: Driver<Bool>
  private(set) var location: Driver<CLLocation>
  
  let error: Observable<NSError>
  let heading: Observable<CLHeading>
  let enteredRegion: Observable<CLRegion>
  let exitedRegion: Observable<CLRegion>
  
  var authorizationGranted: Driver<Void> {
    return authorization.filter { $0 }.mapToVoid()
  }
  
  var authorizationDenied: Driver<Void> {
    return authorization.filter { !$0 }.mapToVoid()
  }
  
  private(set) var locationManager = CLLocationManager()
  
  private var authorizationStatus: CLAuthorizationStatus {
    return CLLocationManager.authorizationStatus()
  }
  
  var isAuthorized: Bool {
    return authorizationStatus == type(of: self).desiredAuthorizationStatus
  }
  
  var lastLocation: CLLocation? {
    if let location = Defaults[.location], location.horizontalAccuracy > 0 {
      if Date().timeIntervalSince(location.timestamp) < 30.minutes {
        return location
      }
    }
    return nil
  }
  
  override init() {
    locationManager.distanceFilter = 1000 //kCLDistanceFilterNone // every 1000 meters
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.headingFilter = 2.0
    
    let desiredStatus = type(of: self).desiredAuthorizationStatus
    
    authorization = Observable<CLAuthorizationStatus>.deferred {
      [weak locationManager] () -> Observable<CLAuthorizationStatus> in
      
      let authorizationStatus = CLLocationManager.authorizationStatus()
      
      guard let locationManager = locationManager else {
        return Observable.just(authorizationStatus)
      }
      return locationManager.rx.didChangeAuthorizationStatus
      }
      .asDriver(onErrorJustReturn: .notDetermined)
      .map { $0 == desiredStatus }
    
    error = locationManager.rx.didFailWithError
    
    if CLLocationManager.headingAvailable() {
      if let startValue = locationManager.heading {
        heading = locationManager.rx.didUpdateHeading.startWith(startValue)
      } else {
        heading = locationManager.rx.didUpdateHeading
      }
    } else {
      heading = Observable<CLHeading>.empty()
    }
    
    enteredRegion = locationManager.rx.didEnterRegion
    exitedRegion = locationManager.rx.didExitRegion
    
    location = locationManager.rx.didUpdateLocations
      .asDriver(onErrorJustReturn: [])
      .flatMap { locations -> Driver<CLLocation> in
        return locations.last.map(Driver.just) ?? Driver.empty()
      }
      .scan(CLLocation(), accumulator: { last, current in
        return last.distance(from: current) >= Defaults[.distanceFilter] ? current : last
      })
      .distinctUntilChanged { lhs, rhs in
        return lhs.coordinate == rhs.coordinate
    }
    super.init()
  }
  
  func routes(to destination: MKMapItem, via: MKDirectionsTransportType)
    -> Observable<MKDirectionsResult> {
      
      return Observable.create { observer in
                
        let request = MKDirectionsRequest()
        
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.requestsAlternateRoutes = false
        request.departureDate = Date()
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
          if let error = error {
            observer.onNext(.failure(error))
          }
          else {
            observer.onNext(
              .success(destination.placemark, response?.routes ?? []))
          }
          observer.onCompleted()
        }
        return Disposables.create {
          directions.cancel()
        }
      }
  }
  
  func start() {
    locationManager.startUpdatingLocation()
    //locationManager.startUpdatingHeading()
  }
  
  func stop() {
    locationManager.stopUpdatingLocation()
    //locationManager.stopUpdatingHeading()
  }
}
