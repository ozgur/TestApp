//
//  UserDefaults.swift
//  TestApp
//
//  Created by Ozgur on 10/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import CoreLocation
import SwiftyUserDefaults

extension UserDefaults {
  subscript(key: DefaultsKey<CLLocation?>) -> CLLocation? {
    get { return unarchive(key) }
    set { archive(key, newValue) }
  }
}

extension DefaultsKeys {
  static let token = DefaultsKey<String>("token")
  static let wasRemoteNotificationPermissionRequested = DefaultsKey<Bool?>("wasRemoteNotificationPermissionRequested")
  static let distanceFilter = DefaultsKey<CLLocationDistance>("distanceFilter")
  static let location = DefaultsKey<CLLocation?>("location")
}
