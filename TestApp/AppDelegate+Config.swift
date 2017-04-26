//
//  AppDelegate+Config.swift
//  TestApp
//
//  Created by Ozgur on 26/04/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import AlamofireNetworkActivityIndicator
import GoogleMaps
import SwiftyBeaver
import UIKit

extension AppDelegate {
  
  private func configureNetworkActivityIndicator() {
    NetworkActivityIndicatorManager.shared.isEnabled = true
    NetworkActivityIndicatorManager.shared.startDelay = 1.0
    NetworkActivityIndicatorManager.shared.completionDelay = 0.5
  }
  
  private func configureLogger() {
    let console = ConsoleDestination()
    console.format = "$Dyyyy/MM/dd HH:mm:ss.SSS$d $C$N.$F$c:$l $L: $M"
    console.asynchronously = false // TODO: true for production
    logger.addDestination(console)
  }
  
  private func configureUIAppearance() {
    UILabel.appearance().textColor = R.blackTextColor
    UILabel.appearance().font = R.defaultFont(ofSize: 15)
  }
  
  private func configureGoogleMapsAPI() {
    GMSServices.provideAPIKey(Config.default.GoogleMapsAPIKey)
  }
  
  func configure() {
    configureUIAppearance()
    configureLogger()
    configureNetworkActivityIndicator()
    configureGoogleMapsAPI()
  }
}
