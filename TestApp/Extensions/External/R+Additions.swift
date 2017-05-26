//
//  R+Additions.swift
//  TestApp
//
//  Created by Ozgur on 28/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import HEXColor
import UIKit

extension R {
  
  static let blackTextColor = UIColor("#323232")
  static let whiteTextColor = UIColor("#f9f9f9")
  static let failureColor = UIColor("#ee1c01")
  static let successColor = UIColor("#4bb543")
  static let routeColor = UIColor("#4285f4")
  static let radarColor = UIColor("#f07177").withAlphaComponent(0.2)
  
  static func defaultFont(ofSize fontSize: CGFloat, heavy: Bool = false) -> UIFont! {
    if heavy {
      return font.clanNews(size: fontSize.font)
    } else {
      return font.clanBook(size: fontSize.font)
    }
  }
  
  static func thinFont(ofSize fontSize: CGFloat) -> UIFont! {
    return font.clanThin(size: fontSize.font)
  }
  
  static func mediumFont(ofSize fontSize: CGFloat) -> UIFont! {
    return font.clanMedium(size: fontSize.font)
  }
  
  static func boldFont(ofSize fontSize: CGFloat) -> UIFont! {
    return font.clanBold(size: fontSize.font)
  }
  
  static func bolderFont(ofSize fontSize: CGFloat) -> UIFont! {
    return font.clanBlack(size: fontSize.font)
  }
  
  static func boldestFont(ofSize fontSize: CGFloat) -> UIFont! {
    return font.clanBlack(size: fontSize.font)
  }
}


