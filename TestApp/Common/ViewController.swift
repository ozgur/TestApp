//
//  ViewController.swift
//  TestApp
//
//  Created by Ozgur on 17/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import NVActivityIndicatorView
import RxCocoa
import RxOptional
import RxSwift
import UIKit

class ViewController: UIViewController, NVActivityIndicatorViewable {
    
  var message: String?
  
  private let isPresented  = BehaviorSubject<Bool?>(value: nil)
  
  var controllerWasPresented: Driver<Void> {
    return isPresented
      .asDriver(onErrorJustReturn: false)
      .filterNil()
      .filter { $0 }
      .mapToVoid()
  }
  
  deinit {
    isPresented.onCompleted()
    NotificationCenter.default.removeObserver(self)
  }
  
  override func present(_ viewControllerToPresent: UIViewController,
                        animated flag: Bool, completion: (() -> Void)? = nil) {
    
    super.present(viewControllerToPresent, animated: flag) {
      completion?()
      
      if let vC = viewControllerToPresent as? ViewController {
        vC.isPresented.onNext(true)
      }
      else {
        // Check if presented view controller is a container.
        if let navC = viewControllerToPresent as? UINavigationController,
          let vC = navC.rootViewController as? ViewController {
          vC.isPresented.onNext(true)
        }
        else if let tabC = viewControllerToPresent as? UITabBarController,
          let vC = tabC.selectedViewController as? ViewController {
          vC.isPresented.onNext(true)
        }
      }
    }
  }
  
  func startAnimating() {
    let size = CGSize(width: 40, height: 40)
    let messageFont = R.defaultFont(ofSize: 15.0, heavy: true)
    
    let data = ActivityData(
      size: size, message: message, messageFont: messageFont,
      type: .ballScaleMultiple, color: .white
    )
    startAnimating(data)
  }
  
  override func stopAnimating() {
    self.message = nil
    super.stopAnimating()
  }
  
  override func setActivityMessage(_ message: String?) {
    self.message = message
    super.setActivityMessage(message)
  }
}
