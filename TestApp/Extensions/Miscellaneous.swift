//
//  Miscellaneous.swift
//  TestApp
//
//  Created by Ozgur on 18/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import Device
import SwiftyBeaver
import UIKit

// MARK: Data

extension Data {
  static let Empty = Data()
  static let Error = Data(base64Encoded: "ZXJyb3I=")
  
  var deviceToken: String {
    return map { String(format: "%02.2hhx", $0) }.joined()
  }
}

// MARK: NSObject

extension NSObject {
  
  var application: AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }
  
  var logger: SwiftyBeaver.Type {
    return SwiftyBeaver.self
  }
}

// MARK: UIApplication

extension UIApplication {
  
  var statusBarHeight: CGFloat {
    return min(statusBarFrame.size.height, statusBarFrame.size.width)
  }
  
  func openURL(_ URLString: String, completionHandler: ((Bool) -> Void)? = nil) {
    if let url = URL(string: URLString) {
      if canOpenURL(url) {
        open(url, options: [:], completionHandler: completionHandler)
      }
    }
  }
}

// MARK: CGFloat

extension CGFloat {

  var font: CGFloat {
    switch Device.size() {
    case .screen3_5Inch:
      return self - 2.0
    case .screen4Inch:
      return self - 1.0
    case .screen4_7Inch:
      return self
    case .screen5_5Inch:
      return self + 1.0
    case .screen7_9Inch, .screen9_7Inch:
      return self + 2.0
    case .screen12_9Inch:
      return self + 3.0
    default:
      return self
    }
  }
}

// MARK: Int

extension Int {
  var minutes: TimeInterval {
    return TimeInterval(self * 60)
  }
}

// MARK: UIDevice

extension UIDevice {
  
  static var identifier: String {
    return UIDevice.current.identifierForVendor?.uuidString ?? String.Empty
  }
}
