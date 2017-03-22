//
//  UIControl+Additions.swift
//  TestApp
//
//  Created by Ozgur on 14/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import UIKit

// MARK: UIControl

extension UIControl {
  
  func removeAllTargets() {
    self.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
  }
  
  func addTarget(_ target: AnyObject?, forTouchUpInsideEvent action: Selector) {
    self.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
  }
}
