//
//  UIView+Additions.swift
//  TestApp
//
//  Created by Ozgur on 14/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import UIKit

// MARK: UIView
  
extension UIView {

  convenience init(frame: CGRect, background: UIColor) {
    self.init(frame: frame)
    self.backgroundColor = background
  }
  
  convenience init(background: UIColor) {
    self.init(frame: CGRect.zero, background: background)
  }
  
  func addSubviews(_ views: UIView...) {
    for view in views {
      self.addSubview(view)
    }
  }
  
  func removeAllSubviews() {
    for subview: UIView in subviews {
      subview.removeFromSuperview()
    }
  }
  
  func removeAllGestureRecognizers() {
    for gestureRecognizer: UIGestureRecognizer in gestureRecognizers ?? [] {
      self.removeGestureRecognizer(gestureRecognizer)
    }
  }
  
  func toImage() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
    self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image!
  }
  
  func transformToIdentity() {
    transform = .identity
  }
  
  // Animation helpers
  
  class func animate(withDuration duration: TimeInterval, damping: CGFloat, velocity: CGFloat,
                     options: UIViewAnimationOptions, animations: @escaping () -> Void) {
    self.animate(withDuration: duration, delay: 0.0,
                 usingSpringWithDamping: damping, initialSpringVelocity: velocity,
                 options: options, animations: animations, completion: nil)
  }
  
  class func animate(withDuration duration: TimeInterval, options: UIViewAnimationOptions,
                     animations: @escaping () -> Void,
                     completion: ((Bool) -> Void)?) {
    self.animate(withDuration: duration, delay: 0.0, options: options,
                 animations: animations, completion: completion)
  }
  
  class func animate(withDuration duration: TimeInterval, options: UIViewAnimationOptions,
                     animations: @escaping () -> Void) {
    self.animate(withDuration: duration, options: options, animations: animations, completion: nil)
  }
}

// MARK: CALayer

extension CALayer {
  
  func removeAllSublayers() {
    for layer: CALayer in sublayers ?? [] {
      layer.removeFromSuperlayer()
    }
  }
}

