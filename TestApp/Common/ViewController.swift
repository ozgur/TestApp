//
//  ViewController.swift
//  TestApp
//
//  Created by Ozgur on 17/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class ViewController: UIViewController {
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: Rx

extension Reactive where Base: ViewController {
  
  /// Bindable sink for `startAnimating()`, `stopAnimating()` methods.
  var isAnimating: UIBindingObserver<Base, Bool> {
    return UIBindingObserver(UIElement: base) { controller, active in
      if active {
        controller.startAnimating()
      } else {
        controller.stopAnimating()
      }
    }
  }
}
