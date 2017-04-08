//
//  Company.swift
//  TestApp
//
//  Created by Ozgur on 14/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import ObjectMapper
import UIKit

class Company: Mappable {

  var id: Int = NSNotFound
  var name: String!
  var thumbnail: UIImage?

  var icon: UIImage? {
    didSet {
      thumbnail = icon?.resized(
        CGSize(width: 40, height: 40), opaque: false
      )
    }
  }
  
  required init?(map: Map) {}
  
  func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
    icon <- (map["icon"], Base64EncodedImageTransform(.png))
  }
}

// MARK: Equatable

extension Company: Equatable {}

func ==(lhs: Company, rhs: Company) -> Bool {
  return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

// MARK: CustomStringConvertible

extension Company: CustomStringConvertible {
  
  var description: String {
    return "Company <\(name)>"
  }
}
