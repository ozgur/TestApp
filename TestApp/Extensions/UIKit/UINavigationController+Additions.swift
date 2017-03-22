//
//  UIResponder+Additions.swift
//  TestApp
//
//  Created by Ozgur on 14/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import UIKit

extension UINavigationController {

  var rootViewController: UIViewController! {
    return viewControllers.first
  }
}
