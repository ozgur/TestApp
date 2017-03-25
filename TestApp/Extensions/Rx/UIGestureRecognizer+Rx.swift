//
//  UIGestureRecognizer+Rx.swift
//  TestApp
//
//  Created by Ozgur on 24/03/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import RxCocoa
import RxGesture
import RxSwift
import UIKit

// MARK: ObservableType

extension ObservableType where E: UIGestureRecognizer {
  
  func when(_ states: [UIGestureRecognizerState]) -> Observable<E> {
    return filter { gesture in
      return states.contains(gesture.state)
    }
  }
}

extension Reactive where Base: View {
  
  func anyGesture(_ factories: (AnyGestureRecognizerFactory, when: [GestureRecognizerState])...)
    -> ControlEvent<GestureRecognizer> {
      
      let observables = factories.map { gesture, states in
        self.gesture(gesture).when(states).asObservable() as Observable<GestureRecognizer>
      }
      return ControlEvent(events: Observable.from(observables).merge())
  }
}
