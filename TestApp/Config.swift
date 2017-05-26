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
  let GMapsAPIKey: String
  
  private init() {
    let name = Bundle.main.object(
      forInfoDictionaryKey: "CFBundleConfigurationName"
    ) as? String

    let file = Bundle.main.path(forResource: name, ofType: "plist")
    let config = JSON(NSDictionary(contentsOfFile: file!)!)

    baseURL = URL(string: config["BaseURL"].stringValue)!
    GMapsAPIKey = config["GoogleMaps"]["Key"].stringValue
  }
}
