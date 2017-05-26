//
//  Helpers.swift
//  TestApp
//
//  Created by Ozgur on 19/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import Foundation
import MapKit
import SwiftMessages

let kCLLocation2DInvalid = CLLocation(
  coordinate: kCLLocationCoordinate2DInvalid,
  altitude: -1.0,
  horizontalAccuracy: -1.0,
  verticalAccuracy: -1.0,
  course: -1.0,
  speed: -1.0,
  timestamp: Date() // Don't worry, we won't check this unless coordinate is valid.
)

let kCLLocationCoordinate2DZero = CLLocationCoordinate2DMake(0, 0)
// https://en.wikipedia.org/wiki/Geographical_centre_of_Earth
let kCLLocationCoordinate2DCenter = CLLocationCoordinate2DMake(39.0, 34.0)


extension CLLocationCoordinate2D {
  static let center = kCLLocationCoordinate2DCenter
  static let invalid = kCLLocationCoordinate2DInvalid
  static let zero = kCLLocationCoordinate2DZero
}

func CLLocation2DIsValid(_ loc: CLLocation) -> Bool {
  return CLLocationCoordinate2DIsValid(loc.coordinate)
}

func MKCoordinateRegionMakeWithDistance(_ coordinate: CLLocationCoordinate2D,
                                        _ distance: CLLocationDistance)
  -> MKCoordinateRegion {
    return MKCoordinateRegionMakeWithDistance(coordinate, distance, distance)
}
