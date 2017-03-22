//
//  UIImage+Additions.swift
//  TestApp
//
//  Created by Ozgur on 22/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import UIKit

extension UIImage {
  
  convenience init?(color: UIColor, size: CGSize) {
    let rect = CGRect(origin: .zero, size: size)
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let cgImage = image?.cgImage
      else { return nil }

    self.init(cgImage: cgImage)
  }
  
  func resized(_ newSize: CGSize, opaque: Bool = true) -> UIImage? {
    // normalization is required.
    var newSize = newSize
    
    if CGRect(origin: .zero, size: newSize)
      .contains(CGRect(origin: .zero, size: size))
    {
      newSize = size
    }
    else {
      let widthScale = newSize.width / size.width
      let heightScale = newSize.height / size.height
      
      if widthScale < heightScale {
        newSize.height = size.height * widthScale
      } else {
        newSize.width = size.width * heightScale
      }
    }
    UIGraphicsBeginImageContextWithOptions(newSize, opaque, 0)
    
    defer {
      UIGraphicsEndImageContext()
    }
    
    draw(in: CGRect(origin: .zero, size: newSize))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
