//
//  UIViewController+Rx.swift
//  TestApp
//
//  Created by Ozgur on 26/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import RxCocoa
import RxSwift
import NVActivityIndicatorView
import SwiftyBeaver
import SwiftyUserDefaults
import UIKit
import UserNotifications

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

extension Reactive where Base: UIViewController {
  
  var swifty: UIBindingObserver<Base, Messages.Config> {
    return UIBindingObserver(UIElement: base) { controller, config in
      Messages.top.show(config: config)
    }
  }
  
  var reachability: UIBindingObserver<Base, ReachabilityStatus> {
    return UIBindingObserver(UIElement: base) { controller, reachabilityStatus in
      if reachabilityStatus.unreachable {
        var config = Messages.top.defaultConfig
        
        config.theme = .error
        config.message = "reachability-error".localized
        config.identifier = "reachability-message-view"
        
        Messages.top.show(config: config)
      } else {
        Messages.top.hide(identifier: "reachability-message-view")
      }
    }
  }
  
  var locations: UIBindingObserver<Base, Bool> {
    return UIBindingObserver(UIElement: base) { controller, authorized in
      if authorized {
        Messages.top.hide(identifier: "locations-message-view")
      }
      else {
        var config = Messages.top.defaultConfig
        
        config.theme = .error
        config.message = "locations-error".localized
        config.identifier = "locations-message-view"

        Messages.top.show(config: config)
      }
    }
  }
  
  var notifications: UIBindingObserver<Base, UNAuthorizationStatus> {
    return UIBindingObserver(UIElement: base) { controller, status in
      if status == .authorized {
        Messages.top.hide(identifier: "notifications-message-view")
      }
      else if status == .denied {
        var config = Messages.top.defaultConfig
        
        config.theme = .warning
        config.message = "notifications-error".localized
        config.identifier = "notifications-message-view"
        
        Messages.top.show(config: config)
      }
    }
  }
}

extension Reactive where Base: UIViewController {
  
  var viewDidLoad: ControlEvent<Void> {
    let source = methodInvoked(#selector(UIViewController.viewDidLoad))
      .mapToVoid()
    return ControlEvent(events: source)
  }
  
  var viewWillAppear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
      .map { args in
        return try castOrThrow(Bool.self, args[0])
    }
    return ControlEvent(events: source)
  }
  
  var viewDidAppear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
      .map { args in
        return try castOrThrow(Bool.self, args[0])
    }
    return ControlEvent(events: source)
  }
  
  var viewWillLayoutSubviews: ControlEvent<Void> {
    let source = methodInvoked(#selector(UIViewController.viewWillLayoutSubviews))
      .mapToVoid()
    return ControlEvent(events: source)
  }
  
  var viewDidLayoutSubviews: ControlEvent<Void> {
    let source = methodInvoked(#selector(UIViewController.viewDidLayoutSubviews))
      .mapToVoid()
    return ControlEvent(events: source)
  }
  
  var viewWillDisappear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(UIViewController.viewWillDisappear(_:)))
      .map { args in
        return try castOrThrow(Bool.self, args[0])
    }
    return ControlEvent(events: source)
  }
  
  var viewDidDisappear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(UIViewController.viewDidDisappear(_:)))
      .map { args in
        return try castOrThrow(Bool.self, args[0])
    }
    return ControlEvent(events: source)
  }
}
