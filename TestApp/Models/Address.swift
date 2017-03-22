//
//  Address.swift
//  TestApp
//
//  Created by Ozgur on 27/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import ObjectMapper
import UIKit

class Address: Mappable {
  
  var address: String!
  var postalCode: String!
  var phoneNumber: String!
  
  required init?(map: Map) {}
  
  func mapping(map: Map) {
    address <- map["content"]
    postalCode <- map["zipcode"]
    phoneNumber <- map["phone"]
  }
}

// MARK: Equatable

extension Address: Equatable {}

func ==(lhs: Address, rhs: Address) -> Bool {
  return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

// MARK: CustomStringConvertible

extension Address: CustomStringConvertible {
  
  var description: String {
    return address
  }
}
