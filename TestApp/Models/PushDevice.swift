//
//  PushDevice.swift
//  TestApp
//
//  Created by Ozgur on 08/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import ObjectMapper

class PushDevice: Mappable {
  
  var token: String!
  var isActive: Bool = false
  
  var name: String?
  var deviceIdentifier: String?
  
  required init?(map: Map) {}
  
  func mapping(map: Map) {
    token <- map["registration_id"]
    isActive <- map["active"]
    name <- map["name"]
    deviceIdentifier <- map["device_id"]
  }
  
  static let invalid = PushDevice(token: "<invalid>")
  
  init(token: String) {
    self.token = token
  }
}

// MARK: Equatable

extension PushDevice: Equatable {}

func ==(lhs: PushDevice, rhs: PushDevice) -> Bool {
  return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

// MARK: CustomStringConvertible

extension PushDevice: CustomStringConvertible {
  
  var description: String {
    return "APNS <\(token)>"
  }
}
