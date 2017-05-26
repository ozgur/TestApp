//
//  GoogleMaps+Additions.swift
//  TestApp
//
//  Created by Ozgur on 26/04/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import GoogleMaps

// MARK: GMSCameraPosition

extension GMSCameraPosition {
  
  convenience init(withTarget target: CLLocationCoordinate2D, zoom: Float) {
    self.init(target: target, zoom: zoom, bearing: 0, viewingAngle: 0)
  }
  
  convenience init(withTarget target: CLLocationCoordinate2D) {
    self.init(withTarget: target, zoom: 0)
  }
}

// MARK: GMSMapView

extension GMSMapView {

  func zoomToFit(markers: [GMSMarkable], animated: Bool) {
    var mapBounds: GMSCoordinateBounds?
    
    if let coordinate = myLocation?.coordinate {
      mapBounds = GMSCoordinateBounds(coordinate: coordinate, coordinate: coordinate)
    }
    markers.forEach { marker in
      mapBounds = mapBounds?.includingCoordinate(marker.marker.position)
    }
    if let mapBounds = mapBounds {
      
      let cameraUpdate = GMSCameraUpdate.fit(mapBounds, withPadding: 50.0)
      if animated {
        animate(with: cameraUpdate)
      } else {
        moveCamera(cameraUpdate)
      }
    }
  }
}

// MARK: GMSMapStyle

extension GMSMapStyle {
  
  class func from(style: String) -> GMSMapStyle? {
    if let fileURL = Bundle.main.url(forResource: style, withExtension: "json") {
      return try? GMSMapStyle(contentsOfFileURL: fileURL)
    }
    return nil
  }
}

// MARK: GMSMarkable

protocol GMSMarkable: NSObjectProtocol {
  
  var coordinate: CLLocationCoordinate2D { get }
  var marker: GMSMarker { get set }
}
