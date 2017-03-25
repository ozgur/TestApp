//
//  MKMapView+Rx.swift
//  RxCocoa
//
//  Created by Spiros Gerokostas on 04/01/16.
//  Copyright © 2016 Spiros Gerokostas. All rights reserved.
//

import MapKit
import RxSwift
import RxCocoa

// MARK: RxMKMapViewDelegateProxy

class RxMKMapViewDelegateProxy: DelegateProxy, MKMapViewDelegate, DelegateProxyType {
  
  class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
    let mapView: MKMapView = (object as? MKMapView)!
    return mapView.delegate
  }
  
  class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
    let mapView: MKMapView = (object as? MKMapView)!
    mapView.delegate = delegate as? MKMapViewDelegate
  }
}

// MARK: MKMapView

extension Reactive where Base : MKMapView {
  
  /**
   Reactive wrapper for `delegate`.
   
   For more information take a look at `DelegateProxyType` protocol documentation.
   */
  var delegate: DelegateProxy {
    return RxMKMapViewDelegateProxy.proxyForObject(base)
  }
  
  // MARK: Responding to Map Position Changes
  
  var regionWillChangeAnimated: ControlEvent<Bool> {
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionWillChangeAnimated:)))
      .map { a in
        return try castOrThrow(Bool.self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  var regionDidChangeAnimated: ControlEvent<Bool> {
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
      .map { a in
        return try castOrThrow(Bool.self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  // MARK: Loading the Map Data
  
  var willStartLoadingMap: ControlEvent<Void>{
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapViewWillStartLoadingMap(_:)))
      .mapToVoid()
    return ControlEvent(events: source)
  }
  
  var didFinishLoadingMap: ControlEvent<Void>{
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapViewDidFinishLoadingMap(_:)))
      .mapToVoid()
    return ControlEvent(events: source)
  }
  
  var didFailLoadingMap: Observable<NSError>{
    return delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapViewDidFailLoadingMap(_:withError:)))
      .map { a in
        return try castOrThrow(NSError.self, a[1])
    }
  }
  
  // MARK: Responding to Rendering Events
  
  var willStartRenderingMap: ControlEvent<Void>{
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapViewWillStartRenderingMap(_:)))
      .mapToVoid()
    return ControlEvent(events: source)
  }
  
  var didFinishRenderingMap: ControlEvent<Bool> {
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapViewDidFinishRenderingMap(_:fullyRendered:)))
      .map { a in
        return try castOrThrow(Bool.self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  // MARK: Tracking the User Location
  
  var willStartLocatingUser: ControlEvent<Void> {
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapViewWillStartLocatingUser(_:)))
      .mapToVoid()
    return ControlEvent(events: source)
  }
  
  var didStopLocatingUser: ControlEvent<Void> {
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapViewDidStopLocatingUser(_:)))
      .mapToVoid()
    return ControlEvent(events: source)
  }
  
  var didUpdateUserLocation: ControlEvent<MKUserLocation> {
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapView(_:didUpdate:)))
      .map { a in
        return try castOrThrow(MKUserLocation.self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  var didUpdateUserRegion: ControlEvent<MKCoordinateRegion> {
    let source = didUpdateUserLocation
      .map { location -> MKCoordinateRegion in
        return MKCoordinateRegionMakeWithDistance(location.coordinate, 125.0)
    }
    return ControlEvent(events: source)
  }
  
  var didFailToLocateUserWithError: Observable<NSError> {
    return delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapView(_:didFailToLocateUserWithError:)))
      .map { a in
        return try castOrThrow(NSError.self, a[1])
    }
  }
  
  public var didChangeUserTrackingMode:
    ControlEvent<(mode: MKUserTrackingMode, animated: Bool)> {
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapView(_:didChange:animated:)))
      .map { a in
        return (mode: try castOrThrow(Int.self, a[1]),
                animated: try castOrThrow(Bool.self, a[2]))
      }
      .map { (mode, animated) in
        return (mode: MKUserTrackingMode(rawValue: mode)!,
                animated: animated)
    }
    return ControlEvent(events: source)
  }
  
  // MARK: Responding to Annotation Views
  
  var didAddAnnotationViews: ControlEvent<[MKAnnotationView]> {
    let source = delegate
      .methodInvoked(#selector(
        (MKMapViewDelegate.mapView(_:didAdd:))!
          as (MKMapViewDelegate) -> (MKMapView, [MKAnnotationView]) -> Void
        )
      )
      .map { a in
        return try castOrThrow([MKAnnotationView].self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  var annotationViewCalloutAccessoryControlTapped:
    ControlEvent<(view: MKAnnotationView, control: UIControl)> {
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapView(_:annotationView:calloutAccessoryControlTapped:)))
      .map { a in
        return (view: try castOrThrow(MKAnnotationView.self, a[1]),
                control: try castOrThrow(UIControl.self, a[2]))
    }
    return ControlEvent(events: source)
  }
  
  // MARK: Selecting Annotation Views
  
  var didSelectAnnotationView: ControlEvent<MKAnnotationView> {
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapView(_:didSelect:)))
      .map { a in
        return try castOrThrow(MKAnnotationView.self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  var didDeselectAnnotationView: ControlEvent<MKAnnotationView> {
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapView(_:didDeselect:)))
      .map { a in
        return try castOrThrow(MKAnnotationView.self, a[1])
    }
    return ControlEvent(events: source)
  }
  
  var didChangeState:
    ControlEvent<(view: MKAnnotationView, newState: MKAnnotationViewDragState, oldState: MKAnnotationViewDragState)> {
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapView(_:annotationView:didChange:fromOldState:)))
      .map { a in
        return (view: try castOrThrow(MKAnnotationView.self, a[1]),
                newState: try castOrThrow(UInt.self, a[2]),
                oldState: try castOrThrow(UInt.self, a[3]))
      }
      .map { (view, newState, oldState) in
        return (view: view,
                newState: MKAnnotationViewDragState(rawValue: newState)!,
                oldState: MKAnnotationViewDragState(rawValue: oldState)!)
    }
    return ControlEvent(events: source)
  }
  
  // MARK: Managing the Display of Overlays
  
  var didAddOverlayRenderers: ControlEvent<[MKOverlayRenderer]> {
    let source = delegate
      .methodInvoked(#selector(
        (MKMapViewDelegate.mapView(_:didAdd:))!
          as (MKMapViewDelegate) -> (MKMapView, [MKOverlayRenderer]) -> Void
        )
      )
      .map { a in
        return try castOrThrow([MKOverlayRenderer].self, a[1])
    }
    return ControlEvent(events: source)
  }
}

extension Reactive where Base: MKMapView {
  
  var showUserLocation: UIBindingObserver<Base, Bool> {
    return UIBindingObserver(UIElement: base) { mapView, showsUserLocation in
      mapView.showsUserLocation = showsUserLocation
    }
  }
  
  func routes(to: Placemark, via: MKDirectionsTransportType)
    -> Observable<MKDirectionsResult> {
      
      return Observable.create { observer in
        
        let destination = MKMapItem(placemark: to.placemark)
        destination.name = to.name
        destination.phoneNumber = to.address?.phoneNumber
        
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
            observer.onNext(.success(to, response?.routes ?? []))
          }
          observer.onCompleted()
        }
        return Disposables.create {
          directions.cancel()
        }
      }
  }
}

