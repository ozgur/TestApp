//
//  CLLocationManager+Rx.swift
//  TestApp
//
//  Created by Ozgur on 17/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import CoreLocation
import RxCocoa
import RxSwift

// MARK: RxCLLocationManagerDelegateProxy

class RxCLLocationManagerDelegateProxy : DelegateProxy, CLLocationManagerDelegate, DelegateProxyType {
  
  class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
    let locationManager: CLLocationManager = object as! CLLocationManager
    return locationManager.delegate
  }
  
  class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
    let locationManager: CLLocationManager = object as! CLLocationManager
    locationManager.delegate = delegate as? CLLocationManagerDelegate
  }
}

// MARK: CLLocationManager

extension Reactive where Base: CLLocationManager {
  
  var delegate: DelegateProxy {
    return RxCLLocationManagerDelegateProxy.proxyForObject(base)
  }
  
  var didUpdateLocations: Observable<[CLLocation]> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
      .map { a in
        return try castOrThrow([CLLocation].self, a[1])
    }
  }
  
  var didFailWithError: Observable<NSError> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didFailWithError:)))
      .map { a in
        return try castOrThrow(NSError.self, a[1])
    }
  }
  
  var didFinishDeferredUpdatesWithError: Observable<NSError?> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didFinishDeferredUpdatesWithError:)))
      .map { a in
        return try castOptionalOrThrow(NSError.self, a[1])
    }
  }
  
  var didPauseLocationUpdates: Observable<Void> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidPauseLocationUpdates(_:)))
      .mapToVoid()
  }
  
  public var didResumeLocationUpdates: Observable<Void> {
    return delegate.methodInvoked( #selector(CLLocationManagerDelegate.locationManagerDidResumeLocationUpdates(_:)))
      .mapToVoid()
  }
  
  var didUpdateHeading: Observable<CLHeading> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateHeading:)))
      .map { a in
        return try castOrThrow(CLHeading.self, a[1])
    }
  }
  
  var didEnterRegion: Observable<CLRegion> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didEnterRegion:)))
      .map { a in
        return try castOrThrow(CLRegion.self, a[1])
    }
  }
  
  var didExitRegion: Observable<CLRegion> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didExitRegion:)))
      .map { a in
        return try castOrThrow(CLRegion.self, a[1])
    }
  }
  
  var didDetermineStateForRegion: Observable<(state: CLRegionState, region: CLRegion)> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didDetermineState:for:)))
      .map { a in
        let stateNumber = try castOrThrow(NSNumber.self, a[1])
        let state = CLRegionState(rawValue: stateNumber.intValue) ?? CLRegionState.unknown
        let region = try castOrThrow(CLRegion.self, a[2])
        return (state: state, region: region)
    }
  }
  
  var monitoringDidFailForRegionWithError: Observable<(region: CLRegion?, error: NSError)> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:monitoringDidFailFor:withError:)))
      .map { a in
        let region = try castOptionalOrThrow(CLRegion.self, a[1])
        let error = try castOrThrow(NSError.self, a[2])
        return (region: region, error: error)
    }
  }
  
  var didStartMonitoringForRegion: Observable<CLRegion> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didStartMonitoringFor:)))
      .map { a in
        return try castOrThrow(CLRegion.self, a[1])
    }
  }
  
  var didRangeBeaconsInRegion: Observable<(beacons: [CLBeacon], region: CLBeaconRegion)> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didRangeBeacons:in:)))
      .map { a in
        let beacons = try castOrThrow([CLBeacon].self, a[1])
        let region = try castOrThrow(CLBeaconRegion.self, a[2])
        return (beacons: beacons, region: region)
    }
  }
  
  var rangingBeaconsDidFailForRegionWithError: Observable<(region: CLBeaconRegion, error: NSError)> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:rangingBeaconsDidFailFor:withError:)))
      .map { a in
        let region = try castOrThrow(CLBeaconRegion.self, a[1])
        let error = try castOrThrow(NSError.self, a[2])
        return (region: region, error: error)
    }
  }
  
  var didVisit: Observable<CLVisit> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didVisit:)))
      .map { a in
        return try castOrThrow(CLVisit.self, a[1])
    }
  }
  
  var didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:)))
      .map { a in
        let number = try castOrThrow(NSNumber.self, a[1])
        return CLAuthorizationStatus(rawValue: Int32(number.intValue)) ?? .notDetermined
    }
  }
}

// MARK: CLLocationCoordinate2D

extension CLLocationCoordinate2D: CustomStringConvertible {
  public var description: String {
    return "Coordinate: \(latitude), \(longitude)"
  }
}

extension CLLocationCoordinate2D: Equatable { }

public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
  return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

extension ObservableType where E == CLLocation {
  func distinctUntilChanged(meters distance: CLLocationDistance) -> Observable<CLLocation> {
    return distinctUntilChanged({ (lhs, rhs) -> Bool in
      return lhs.distance(from: rhs) >= distance
    })
  }
}



