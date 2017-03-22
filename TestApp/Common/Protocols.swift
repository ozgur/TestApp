//
//  Protocols.swift
//  TestApp
//
//  Created by Ozgur on 08/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import CoreLocation
import Foundation
import RxSwift

protocol GeololoAPI {
  
  var baseURL: URL { get set }
  init(baseURL: String)
  
  func checkAuth() -> Observable<Bool>

  func registerDevice(token: String) -> Observable<PushDevice>
  func unregisterDevice() -> Observable<Void>
  
  func getPlacemarks(location: CLLocation) -> Observable<PlacemarkResponse>
  
  func getLocationViaIP() -> Observable<CLLocation>
}
