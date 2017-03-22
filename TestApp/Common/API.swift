//
//  API.swift
//  TestApp
//
//  Created by Ozgur on 14/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import CoreLocation
import RxAlamofire
import RxCocoa
import RxSwift
import RxSwiftExt
import SwiftyJSON
import SwiftyUserDefaults

class API: GeololoAPI {
  
  static let shared = API(
    baseURL: "http://geololo.herokuapp.com"
  )
  
  var baseURL: URL
  
  required init(baseURL: String) {
    self.baseURL = URL(string: baseURL)!
  }
  
  private func buildURI(path: String) -> String {
    return URL(string: path , relativeTo: baseURL)!
      .absoluteString
  }
  
  func checkAuth() -> Observable<Bool> {
    // This is also just a mock
    let authResult = arc4random() % 5 == 0 ? false : true
    
    return Observable.just(authResult)
      .delay(1.0, scheduler: MainScheduler.instance)
  }
  
  func registerDevice(token: String) -> Observable<PushDevice> {
    
    return SessionManager.default.rx.object(
      .post, buildURI(path: "/api/notifications/apns/"), [
        "registration_id": token,
        "device_id": UIDevice.identifier
      ])
      .observeOn(Dependencies.shared.mainScheduler)
  }
  
  func unregisterDevice() -> Observable<Void> {
    guard Defaults.hasKey(.token)
      else {
        return Observable<Void>.just()
          .observeOn(Dependencies.shared.mainScheduler)
    }    
    return SessionManager.default.rx.json(
      .delete, buildURI(path: "/api/notifications/apns/\(Defaults[.token])/"))
      .mapToVoid()
      .observeOn(Dependencies.shared.mainScheduler)
  }
  
  func getPlacemarks(location: CLLocation) -> Observable<PlacemarkResponse> {
    
    let params: [String : Any] = [
      "full": true, "available": true, "limit": 20,
      "dist": Defaults[.distanceFilter],
      "point": "\(location.coordinate.longitude),\(location.coordinate.latitude)"
    ]
    
    return SessionManager.default.rx.objectArray(
      .get, buildURI(path: "/api/placemarks/placemarks/"), params,
      keyPath: "results", encoding: URLEncoding.default
      )
      .map { PlacemarkResponse(placemarks: $0) }
      .observeOn(Dependencies.shared.mainScheduler)
  }
  
  func getLocationViaIP() -> Observable<CLLocation> {
    
    return RxAlamofire.request(.get, "http://ip-api.com/json")
      .flatMap { request in
        request.validate("application/json", 200).rx.json()
      }
      .observeOn(Dependencies.shared.backgroundWorkScheduler)
      .map { JSON($0) }
      .map { data in
        let latitude = data["lat"].doubleValue
        let longitude = data["lon"].doubleValue
        return CLLocation(latitude: latitude, longitude: longitude)
      }
      .observeOn(Dependencies.shared.mainScheduler)
  }
}
