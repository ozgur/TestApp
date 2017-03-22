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
   Updates the visible area of the map so that all annotations added
   to map are displayed on the map.
   
   - parameter animated: Specify true if you want the map view to
   animate the transition.
   */
  
  func zoomToFitAllAnnotations(animated: Bool) {
    var zoomRect = MKMapRectNull
    
    for annotation in annotations {
      var coordinate = kCLLocationCoordinate2DInvalid
      
      if let userLocation = annotation as? MKUserLocation {
        if let userCoordinate = userLocation.location?.coordinate {
          coordinate = userCoordinate
        }
      }
      else {
        coordinate = annotation.coordinate
      }
      if CLLocationCoordinate2DIsValid(coordinate) {
        let aPoint = MKMapPointForCoordinate(coordinate)
        let aRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
        
        if MKMapRectIsNull(zoomRect) {
          zoomRect = aRect
        }
        else {
          zoomRect = MKMapRectUnion(zoomRect, aRect)
        }
      }
    }
    if !MKMapRectIsNull(zoomRect) {
      let inset = -max(zoomRect.size.height, zoomRect.size.width) * 0.20
      setVisibleMapRect(MKMapRectInset(zoomRect, inset, inset), animated: animated)
    }
  }
  
  /**
   Updates the visible area of the map so that given coordinates are
   all displayed on the map.
   
   - parameter coordinates: Coordinates to be displayed on the map.
   - parameter animated: Specify true if you want the map view to animate the transition.
   */
  func zoomToFit(coordinates: CLLocationCoordinate2D..., animated: Bool) {
    var zoomRect = MKMapRectNull
    
    for coordinate in coordinates {
      if !CLLocationCoordinate2DIsValid(coordinate) {
        continue
      }
      let aPoint = MKMapPointForCoordinate(coordinate)
      let aRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
      
      if MKMapRectIsNull(zoomRect) {
        zoomRect = aRect
      }
      else {
        zoomRect = MKMapRectUnion(zoomRect, aRect)
      }
    }
    
    if let userLocation = userLocation.location {
      let aPoint = MKMapPointForCoordinate(userLocation.coordinate)
      let aRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
      zoomRect = MKMapRectUnion(zoomRect, aRect)
    }
    
    if !MKMapRectIsNull(zoomRect) {
      let inset = -max(zoomRect.size.height, zoomRect.size.width) * 0.2
      UIView.animate(withDuration: 0.5) {
        self.setVisibleMapRect(MKMapRectInset(zoomRect, inset, inset), animated: animated)
      }
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
   Updates region of map using given center coordinate and the radius with animation.
   The duration of the animation is 1.0 seconds.
   
   - parameter coordinate: The center point of the new coordinate region.
   - parameter radius: The amount of distance in meters from the center.
   */
  func setCenterCoordinate(_ coordinate: CLLocationCoordinate2D, withRadius radius: CLLocationDistance) {
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
  func setCenterUserLocation(withRadius radius: CLLocationDistance) {
    setCenterCoordinate(userCoordinate, withRadius: radius)
  }
}
