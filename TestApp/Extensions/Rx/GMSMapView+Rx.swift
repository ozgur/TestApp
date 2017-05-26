//
//  GMSMapView+Rx.swift
//  TestApp
//
//  Created by Ozgur on 26/04/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import GoogleMaps
import RxCocoa
import RxSwift

// MARK: RxGMSMapViewDelegateProxy

class RxGMSMapViewDelegateProxy: DelegateProxy, GMSMapViewDelegate, DelegateProxyType {
  
  class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
    let mapView: GMSMapView = (object as? GMSMapView)!
    return mapView.delegate
  }
  
  class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
    let mapView: GMSMapView = (object as? GMSMapView)!
    mapView.delegate = delegate as? GMSMapViewDelegate
  }
}

// MARK: GMSMapView

extension Reactive where Base : GMSMapView {
  
  /**
   Reactive wrapper for `delegate`.
   
   For more information take a look at `DelegateProxyType` protocol documentation.
   */
  
  var delegate: DelegateProxy {
    return RxGMSMapViewDelegateProxy.proxyForObject(base)
  }
  
  var userLocation: Observable<CLLocation?> {
    return observeWeakly(CLLocation.self, "myLocation")
  }
  
  var willMove: ControlEvent<Bool> {
    let source = delegate.methodInvoked(#selector(GMSMapViewDelegate.mapView(_:willMove:)))
      .map { a in
        return try castOrThrow(Bool.self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  var didChangeCameraPosition: ControlEvent<GMSCameraPosition> {
    let source = delegate.methodInvoked(#selector(GMSMapViewDelegate.mapView(_:didChange:)))
      .map { a in
        return try castOrThrow(GMSCameraPosition.self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  var idleAtCameraPosition: ControlEvent<GMSCameraPosition> {
    let source = delegate.methodInvoked(#selector(GMSMapViewDelegate.mapView(_:idleAt:)))
      .map { a in
        return try castOrThrow(GMSCameraPosition.self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  var didTapAtCoordinate: ControlEvent<CLLocationCoordinate2D> {
    let source = delegate.methodInvoked(#selector(GMSMapViewDelegate.mapView(_:didTapAt:)))
      .map { a in
        return try castOrThrow(CLLocationCoordinate2D.self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  var didLongPressAtCoordinate: ControlEvent<CLLocationCoordinate2D> {
    let source = delegate.methodInvoked(#selector(GMSMapViewDelegate.mapView(_:didLongPressAt:)))
      .map { a in
        return try castOrThrow(CLLocationCoordinate2D.self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  var didTapInfoWindowOfMarker: ControlEvent<GMSMarker> {
    let source = delegate.methodInvoked(#selector(GMSMapViewDelegate.mapView(_:didTapInfoWindowOf:)))
      .map { a in
        return try castOrThrow(GMSMarker.self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  var didLongPressInfoWindowOfMarker: ControlEvent<GMSMarker> {
    let source = delegate.methodInvoked(#selector(GMSMapViewDelegate.mapView(_:didLongPressInfoWindowOf:)))
      .map { a in
        return try castOrThrow(GMSMarker.self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  var didTapMyLocationButton: ControlEvent<Void> {
    let source = delegate.methodInvoked(#selector(GMSMapViewDelegate.didTapMyLocationButton(for:)))
      .mapToVoid()
    return ControlEvent(events: source)
  }
}

extension Reactive where Base: GMSMapView {
  
  var showUserLocation: UIBindingObserver<Base, Bool> {
    return UIBindingObserver(UIElement: base) { mapView, showsUserLocation in
      mapView.isMyLocationEnabled = showsUserLocation
      mapView.settings.myLocationButton = showsUserLocation
    }
  }
}
