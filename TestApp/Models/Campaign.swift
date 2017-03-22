//
//  Campaign.swift
//  TestApp
//
//  Created by Ozgur on 20/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import ObjectMapper

class Campaign: Mappable {
  
  var startsAt: Date!
  var endsAt: Date!
  var message: String!
  var text: String?
  var link: URL?
  var isActive: Bool = false
  
  required init?(map: Map) {}
  
  func mapping(map: Map) {
    isActive <- map["active"]
    startsAt <- (map["starts_at"], ISO8601DateTransform())
    endsAt <- (map["ends_at"], ISO8601DateTransform())
    message <- map["message"]
    text <- map["text"]
  }
}

// MARK: Equatable

extension Campaign: Equatable {}

func ==(lhs: Campaign, rhs: Campaign) -> Bool {
  return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

// MARK: CustomStringConvertible

extension Campaign: CustomStringConvertible {
  
  var description: String {
    return "Campaign <\(message)>"
  }
}
