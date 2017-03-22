//
//  Wireframe.swift
//  TestApp
//
//  Created by Ozgur on 27/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import RxSwift
import UIKit

class Wireframe {
  
  static let shared = Wireframe()
  
  func open(url: URL) {
    UIApplication.shared.openURL(url.absoluteString)
  }
  
  private static func rootViewController() -> UIViewController {
    return UIApplication.shared.keyWindow!.rootViewController!
  }
  
  static func presentAlert(_ message: String) {
    let alertView = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alertView.addAction(UIAlertAction(title: localize("OK"), style: .cancel) { _ in
    })
    rootViewController().present(alertView, animated: true, completion: nil)
  }
  
  func promptFor<Action : CustomStringConvertible>(_ message: String, cancelAction: Action,
                 actions: [Action]) -> Observable<Action> {

    return Observable.create { observer in
      let alertView = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      alertView.addAction(UIAlertAction(title: cancelAction.description, style: .cancel) { _ in
        observer.on(.next(cancelAction))
      })
      
      for action in actions {
        alertView.addAction(UIAlertAction(title: action.description, style: .default) { _ in
          observer.on(.next(action))
        })
      }
      
      Wireframe.rootViewController().present(alertView, animated: true, completion: nil)
      
      return Disposables.create {
        alertView.dismiss(animated:false, completion: nil)
      }
    }
  }
}
