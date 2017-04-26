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
  
  func setTranslatesAutoresizingMaskIntoConstraintsIfRequired() {
    if parent == nil {
      view.translatesAutoresizingMaskIntoConstraints = true
    }
    if navigationController != nil {
      view.translatesAutoresizingMaskIntoConstraints = true
    }
  }
}

// MARK: NVActivityIndicatorViewable

extension UIViewController: NVActivityIndicatorViewable {
    
  func startAnimating(message: String? = nil) {
    let size = CGSize(width: 40, height: 40)
    let messageFont = R.defaultFont(ofSize: 15.0, heavy: true)
    let activityData = ActivityData(
      size: size, message: message, messageFont: messageFont,
      type: .ballScaleMultiple, color: .white
    )
    Dependencies.shared.activity.startAnimating(activityData)
  }
  
  func stopAnimating() {
    Dependencies.shared.activity.stopAnimating()
  }
  
  func setActivityMessage(_ message: String?) {
    Dependencies.shared.activity.setMessage(message)
  }
}
