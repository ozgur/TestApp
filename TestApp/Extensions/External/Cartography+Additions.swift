//
//  Cartography+Additions.swift
//  TestApp
//
//  Created by Ozgur on 28/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import Cartography

@discardableResult
func align(_ edges: [NSLayoutAttribute], _ first: LayoutProxy,
           _ second: LayoutProxy) -> [NSLayoutConstraint] {

  var constraints = [NSLayoutConstraint]()
  
  for edge in edges {
    switch edge {
    case .left:
      constraints.append(contentsOf: align(left: first, second))
    case .top:
      constraints.append(contentsOf: align(top: first, second))
    case .right:
      constraints.append(contentsOf: align(right: first, second))
    case .bottom:
      constraints.append(contentsOf: align(bottom: first, second))
    case .leading:
      constraints.append(contentsOf: align(leading: first, second))
    case .trailing:
      constraints.append(contentsOf: align(trailing: first, second))
    case .centerX:
      constraints.append(contentsOf: align(centerX: first, second))
    case .centerY:
      constraints.append(contentsOf: align(centerY: first, second))
    case .lastBaseline:
      constraints.append(contentsOf: align(baseline: first, second))
    default:
      break
    }
  }
  return constraints
}

func inset(_ edges: Edges, _ insets: UIEdgeInsets) -> Expression<Edges> {
  return inset(edges, insets.top, insets.left, insets.bottom, insets.right)
}
