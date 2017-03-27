//
//  UIViewController+Rx.swift
//  TestApp
//
//  Created by Ozgur on 26/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftyBeaver
import SwiftyUserDefaults
import UIKit
import UserNotifications

private func showMessage(_ show: Bool, manager: Messages,
                         config: Messages.Config) {
  if show {
    manager.show(config: config)
  } else {
    manager.hide(identifier: config.identifier)
  }
}

extension Reactive where Base: UIViewController {
  
  var message: UIBindingObserver<Base, (Bool, Messages, Messages.Config)> {
    return UIBindingObserver(UIElement: base) { controller, context in
      let (show, manager, config) = context
      showMessage(show, manager: manager, config: config)
    }
  }
  
  var reachability: UIBindingObserver<Base, ReachabilityStatus> {
    return UIBindingObserver(UIElement: base) { controller, status in
      var config = Messages.top.defaultConfig
      
      config.theme = .error
      config.message = "reachability-error".localized
      config.identifier = "reachability-message-view"
      
      showMessage(status.unreachable, manager: .top, config: config)
    }
  }
  
  var locations: UIBindingObserver<Base, Bool> {
    return UIBindingObserver(UIElement: base) { controller, authorized in
      var config = Messages.top.defaultConfig
      
      config.theme = .error
      config.message = "locations-error".localized
      config.identifier = "locations-message-view"

      showMessage(!authorized, manager: .top, config: config)
    }
  }
  
  var notifications: UIBindingObserver<Base, UNAuthorizationStatus> {
    return UIBindingObserver(UIElement: base) { controller, status in
      var config = Messages.top.defaultConfig
      
      config.theme = .warning
      config.message = "notifications-error".localized
      config.identifier = "notifications-message-view"
      config.duration = 5.0

      showMessage(status != .authorized, manager: .top, config: config)
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
