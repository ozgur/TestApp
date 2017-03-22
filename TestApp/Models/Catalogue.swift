//
//  Catalogue.swift
//  TestApp
//
//  Created by Ozgur on 15/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import ObjectMapper

class Catalogue: Mappable {
  
  var id: Int = NSNotFound
  var name: String!
  var companies: [Company] = []
  
  required init?(map: Map) {}
  
  func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
    companies <- map["companies"]
  }
}

// MARK: Equatable

extension Catalogue: Equatable {}

func ==(lhs: Catalogue, rhs: Catalogue) -> Bool {
  return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

// MARK: CustomStringConvertible

extension Catalogue: CustomStringConvertible {
  
  var description: String {
    return "Catalogue <\(name)>"
  }
}
