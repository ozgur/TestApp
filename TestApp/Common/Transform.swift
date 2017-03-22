//
//  Transform.swift
//  TestApp
//
//  Created by Ozgur on 22/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import ObjectMapper
import UIKit

enum ImageTransformType {
  case jpeg, png
}

// MARK: Base64EncodedImageTransform

class Base64EncodedImageTransform: TransformType {
  typealias Object = UIImage
  typealias JSON = String
  
  let type: ImageTransformType
  
  init(_ type: ImageTransformType) {
    self.type = type
  }
  
  func transformFromJSON(_ value: Any?) -> UIImage? {
    if let value = value as? String, let url = URL(string: value),
      let data = try? Data(contentsOf: url) {
      return UIImage(data: data)
    }
    return nil
  }
  
  func transformToJSON(_ value: UIImage?) -> String? {
    if let value = value {
      switch type {
      case .png:
        return UIImagePNGRepresentation(value)?.base64EncodedString()
      case .jpeg:
        return UIImageJPEGRepresentation(value, 1.0)?.base64EncodedString()
      }
    }
    return nil
  }
}
