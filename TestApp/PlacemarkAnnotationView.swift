//
//  PlacemarkAnnotationView.swift
//  TestApp
//
//  Created by Ozgur on 21/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import MapKit
import UIKit

/// Annotation view responsible for showing a placemark object on the map.
class PlacemarkAnnotationView: MKAnnotationView {
  
  /// A flag to decide whether annotation dropping will be animated or not.
  var animatesDrop: Bool = false

  /// Underlying annotation as a placemark. It will crash if annotation is nil.
  var placemark: Placemark {
    return annotation as! Placemark
  }
}

/// A circle used to show the radar circle around a placemark.
class PlacemarkRadar: MKCircle {
  
  convenience init(placemark: Placemark, radius: CLLocationDistance) {
    self.init()
    self.init(center: placemark.coordinate, radius: radius)
  }
}
