//
//  NVActivityIndicatorView+Additions.swift
//  TestApp
//
//  Created by Ozgur on 26/04/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import NVActivityIndicatorView

extension ActivityData {
  
  convenience init(message: String) {
    self.init(
      size: CGSize(width: 40, height: 40),
      message: message,
      messageFont: R.defaultFont(ofSize: 15.0, heavy: true),
      type: NVActivityIndicatorType.ballScaleMultiple,
      color: UIColor.white
    )
  }
}
