//
//  Placemark.swift
//  TestApp
//
//  Created by Ozgur on 14/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import CoreLocation
import GoogleMaps
import ObjectMapper

// MARK: Placemark

class Placemark: NSObject, Mappable, GMSMarkable {
  
  var name: String! {
    didSet {
      marker.title = name
    }
  }
  
  var slug: String!
  var attendant: String?
  var info: String?
  
  var id: Int = NSNotFound
  var isAvailable: Bool = false
  var coordinate = kCLLocationCoordinate2DInvalid {
    didSet {
      marker.position = coordinate
    }
  }
  var company: Company? {
    didSet {
      marker.snippet = company?.name
      marker.icon = company?.thumbnail
    }
  }
  var campaigns: [Campaign] = []
  var address: Address?
  
  required init?(map: Map) {}
  
  override init() {
    super.init()
  }
  
  fileprivate static let invalid = Placemark()
  
  func mapping(map: Map) {
    name <- map["name"]
    slug <- map["slug"]
    attendant <- map["attendant"]
    info <- map["description"]
    id <- map["id"]
    isAvailable <- map["available"]
    company <- map["company"]
    coordinate <- (
      map["coordinate.coordinates"], PlacemarkCoordinateTransform()
    )
    campaigns <- map["campaigns"]
    address <- map["content"]
    if address == nil {
      address <- map["address"]
    }
  }
  
  var marker: GMSMarker = {
    let marker = GMSMarker()
    marker.appearAnimation = GMSMarkerAnimation.pop
    marker.tracksInfoWindowChanges = true
    return marker
  }()

  var radar: PlacemarkRadar {
    return PlacemarkRadar(placemark: self, radius: 300.0)
  }
  
  override var description: String {
    return "Placemark <\(name)>"
  }
}

func ==(lhs: Placemark, rhs: Placemark) -> Bool {
  return lhs.coordinate == rhs.coordinate
}


// MARK: PlacemarkCoordinateTransform

fileprivate class PlacemarkCoordinateTransform: TransformType {
  
  fileprivate typealias Object = CLLocationCoordinate2D
  fileprivate typealias JSON = [CLLocationDegrees]
  
  fileprivate init() {}
  
  fileprivate func transformFromJSON(_ value: Any?) -> CLLocationCoordinate2D? {
    if let coordinates = value as? [CLLocationDegrees], coordinates.count == 2 {
      return CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
    }
    return kCLLocationCoordinate2DInvalid
  }
  
  fileprivate func transformToJSON(_ value: CLLocationCoordinate2D?) -> Array<CLLocationDegrees>? {
    if let value = value {
      return [value.longitude, value.longitude]
    }
    return nil
  }
}

// MARK: PlacemarkResponse

struct PlacemarkResponse: Equatable {
  
  static let invalid = PlacemarkResponse(placemarks: [.invalid])

  let placemarks: [Placemark]
  
  init(placemarks: [Placemark]) {
    self.placemarks = placemarks
  }
}

func ==(lhs: PlacemarkResponse, rhs: PlacemarkResponse) -> Bool {
  return lhs.placemarks == rhs.placemarks
}
