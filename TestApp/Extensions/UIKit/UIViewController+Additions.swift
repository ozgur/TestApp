//
//  UIViewController+Additions.swift
//  TestApp
//
//  Created by Ozgur on 14/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import NVActivityIndicatorView
import RxCocoa
import UIKit

extension UIViewController {
  
  var $: Dependencies {
    return Dependencies.shared
  }
  
  var navigationBar: UINavigationBar? {
    return navigationController?.navigationBar
  }
    
  func startAnimating(_ data: ActivityData) {
    Dependencies.shared.activity.startAnimating(data)
  }
  
  func stopAnimating() {
    Dependencies.shared.activity.stopAnimating()
  }
  
  func setActivityMessage(_ message: String?) {
    Dependencies.shared.activity.setMessage(message)
  }
  
  func setTranslatesAutoresizingMaskIntoConstraintsIfRequired() {
    if parent == nil {
      view.translatesAutoresizingMaskIntoConstraints = true
    }
    if navigationController != nil {
      view.translatesAutoresizingMaskIntoConstraints = true
    }
  }
}
