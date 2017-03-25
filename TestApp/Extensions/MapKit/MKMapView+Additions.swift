//
//  MKMapView+Additions.swift
//  TestApp
//
//  Created by Ozgur on 20/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import MapKit

// MARK: MKDirectionsResult

enum MKDirectionsResult {
  case failure(Error)
  case success(Placemark, [MKRoute])
}

// MARK: MKMapView

extension MKMapView {
  
  convenience init(frame: CGRect, delegate: MKMapViewDelegate?) {
    self.init(frame: frame)
    self.delegate = delegate
  }
  
  /// User's location. Returns kCLLocationCoordinate2DInvalid if not found.
  var userCoordinate: CLLocationCoordinate2D {
    return userLocation.location?.coordinate ?? kCLLocationCoordinate2DInvalid
  }
  
  /**
   Returns map's current zoom level. When set, it updates the region.
   
   To apply new zoom with animation, please use `setZoomLevel(animated:)` method.
   */
  var zoomLevel: Double {
    get {
      return log2(360 * ((Double(frame.size.width) / 256.0) / region.span.longitudeDelta)) + 1.0
    }
    set {
      setZoomLevel(newValue, animated: false)
    }
  }
  
  func setZoomLevel(_ zoomLevel: Double, animated: Bool) {
    let span = MKCoordinateSpanMake(0, 360 / pow(2, zoomLevel) * Double(frame.size.width / 256.0))
    setRegion(MKCoordinateRegionMake(centerCoordinate, span), animated: animated)
  }
  
  /**
   Updates the visible area of the map so that all annotations added
   to map are displayed on the map.
   
   - parameter animated: Specify true if you want the map view to
   animate the transition.
   */
  func zoomToFitAllAnnotations(animated: Bool) {
    let coordinates = annotations
      .mapFilter { annotation in
        return (annotation is MKUserLocation) ? nil : annotation.coordinate
    }
    zoomToFit(coordinates: coordinates, animated: animated)
  }
  
  /**
   Updates the visible area of the map so that given coordinates are
   all displayed on the map.
   
   - parameter coordinates: Coordinates to be displayed on the map.
   - parameter animated: Specify true if you want the map view to animate the transition.
   */
  func zoomToFit(coordinates: [CLLocationCoordinate2D], animated: Bool) {
    let pinSize = MKMapSizeMake(0.1, 0.1)
    var mapRect = MKMapRectNull
    
    var locations = [CLLocationCoordinate2D]()
    if let userLocation = userLocation.location?.coordinate {
      locations.append(userLocation)
    }
    locations.append(contentsOf: coordinates)
    
    for location in locations {
      guard CLLocationCoordinate2DIsValid(location) else { continue }
      
      let aRect = MKMapRect(origin: MKMapPointForCoordinate(location), size: pinSize)
      
      mapRect = MKMapRectIsNull(mapRect) ? aRect : MKMapRectUnion(mapRect, aRect)
    }
    
    // There is nothing to show if map rect is null.
    if MKMapRectIsNull(mapRect) { return }
    
    if MKMapSizeEqualToSize(pinSize, mapRect.size) {
      // There'll be only one pin on the map.
      mapRect = MKMapRectForCoordinateRegion(
        MKCoordinateRegionMakeWithDistance(locations.first!, 1500, 1500)
      )
    }
    else {
      let inset = max(mapRect.size.height, mapRect.size.width) * 0.2
      mapRect = MKMapRectInset(mapRect, -inset, -inset)
    }
    if animated {
      UIView.animate(withDuration: 0.4) {
        self.setVisibleMapRect(mapRect, animated: true)
      }
    } else {
      setVisibleMapRect(mapRect, animated: false)
    }
  }
  
  /// Removes all annotations from the map.
  func removeAllAnnotations() {
    removeAnnotations(annotations)
  }
  
  /**
   Removes overlays of given type from the map.
   
   - parameter type: Type of overlays you want to remove from map.
   */
  func removeOverlays<T: MKOverlay>(ofType type: T.Type) {
    removeOverlays(overlays.filter { $0.isKind(of: type.self) })
  }
  
  /**
   Checks if any overlay of given type exists on the map's overlays array.
   
   - parameter type: Type of overlays you want to check exists.
   */
  func hasOverlays<T: MKOverlay>(ofType type: T.Type) -> Bool {
    return overlays.any { $0.isKind(of: type.self) }
  }
  
  /**
   Updates region of map using given center coordinate and the radius with animation.
   The duration of the animation is 1.0 seconds.
   
   - parameter coordinate: The center point of the new coordinate region.
   - parameter radius: The amount of distance in meters from the center.
   */
  func setCenter(_ coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
    UIView.animate(withDuration: 1.0) {
      self.setRegion(
        MKCoordinateRegionMakeWithDistance(coordinate, radius, radius), animated: true)
    }
  }
  
  /**
   Updates region of map using the current location of the user and the radius.
   Internally calls MapView.setCenterCoordinate(withRadius:)
   
   - parameter coordinate: The center point of the new coordinate region.
   - parameter radius: The amount of distance in meters from the center.
   */
  func setCenterUserLocation(radius: CLLocationDistance) {
    setCenter(userCoordinate, radius: radius)
  }
}

/// Converts a region to a map rectangle.
func MKMapRectForCoordinateRegion(_ region: MKCoordinateRegion) -> MKMapRect {
  let aPoint = MKMapPointForCoordinate(
    CLLocationCoordinate2DMake(
      region.center.latitude + region.span.latitudeDelta / 2,
      region.center.longitude - region.span.longitudeDelta / 2
    )
  )
  let bPoint = MKMapPointForCoordinate(
    CLLocationCoordinate2DMake(
      region.center.latitude - region.span.latitudeDelta / 2,
      region.center.longitude + region.span.longitudeDelta / 2
    )
  )
  return MKMapRectMake(
    min(aPoint.x, bPoint.x),
    min(aPoint.y, bPoint.y),
    abs(aPoint.x - bPoint.x),
    abs(aPoint.y - bPoint.y)
  )
}
