//
//  Config.swift
//  TestApp
//
//  Created by Ozgur on 26/04/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Config {
  
  static let `default` = Config()
  
  let baseURL: URL
  let GoogleMapsAPIKey: String
  
  private init() {
    let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleConfigurationName")
    let file = Bundle.main.path(forResource: name as? String, ofType: "plist")
    let config = JSON(NSDictionary(contentsOfFile: file!)!)

    baseURL = URL(string: config["BaseURL"].stringValue)!
    GoogleMapsAPIKey = config["GoogleMaps"]["Key"].stringValue
  }
}
