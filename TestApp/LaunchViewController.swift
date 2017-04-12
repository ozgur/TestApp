//
//  LaunchViewController.swift
//  TestApp
//
//  Created by Ozgur on 28/12/2016.
//  Copyright © 2016 Ozgur. All rights reserved.
//

import Cartography
import RxCocoa
import RxSwift
import RxSwiftExt
import UIKit

class LaunchViewController: ViewController {
  
  fileprivate enum MoveDirection {
    case left, right
  }
  
  fileprivate var scrollView: UIScrollView!
  fileprivate var imageView: UIImageView!
  
  fileprivate var imageMoveDirection = MoveDirection.right
  fileprivate let transition = BubbleTransition()
  
  // MARK: View cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    scrollView = UIScrollView(frame: .zero)
    scrollView.delegate = self
    
    imageView = UIImageView(image: R.image.turkey())
    
    scrollView.addSubview(imageView)
    view.addSubview(scrollView)
    
    constrain(scrollView, view, block: { scrollView, view in
      scrollView.size == view.size
      scrollView.edges == inset(view.edges, 0.0)
    })
    setTranslatesAutoresizingMaskIntoConstraintsIfRequired()
    setupRx()
  }
  
  private func setupRx() {
    // Laying out UI
    
    rx.viewDidLayoutSubviews
      .subscribe(onNext: configureScrollView)
      .addDisposableTo(rx_disposeBag)
    
    // Show permission dialog
    
    Observable<Int>
      .interval(0.011, scheduler: $.serialWorkScheduler)
      .mapToVoid()
      .takeUntil($.permissionService.prompt().asObservable())
      .observeOn($.mainScheduler)
      .subscribe(
        onNext: slideImageHorizontally,
        onCompleted: presentHomeViewController
      )
      .addDisposableTo(rx_disposeBag)
  }
  
  private func presentHomeViewController() {
    startAnimating()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      
      let viewController = UINavigationController(
        rootViewController: HomeViewController()
      )
      viewController.transitioningDelegate = self
      viewController.modalPresentationStyle = .custom
      
      self.present(viewController, animated: true, completion: nil)
      self.stopAnimating()
    }
  }
  
  private func configureScrollView() {
    scrollView.contentSize = imageView.frame.size
    scrollView.contentOffset.x = (
      scrollView.contentSize.width - scrollView.frame.width
      ) / 2.0
    
    scrollView.minimumZoomScale = 1.0
    scrollView.maximumZoomScale = 1.0
    scrollView.zoomScale = 1.0
    
    let minScale = max(
      scrollView.frame.width / imageView.bounds.width,
      scrollView.frame.height / imageView.bounds.height
    )
    scrollView.minimumZoomScale = minScale
    scrollView.zoomScale = minScale
  }
  
  private func slideImageHorizontally() {
    let offsetX = [.left: -1, .right: 1][imageMoveDirection]! * CGFloat(0.5)
    let maxX = scrollView.contentSize.width - scrollView.frame.width
    
    let newX = max(0, min(scrollView.contentOffset.x + offsetX, maxX))
    
    if scrollView.contentOffset.x + offsetX < 0 {
      imageMoveDirection = .right
    }
    if scrollView.contentOffset.x + offsetX > maxX {
      imageMoveDirection = .left
    }
    scrollView.contentOffset.x = newX
  }
}

// MARK: UIScrollViewDelegate

extension LaunchViewController: UIScrollViewDelegate {
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
}

// MARK: UIViewControllerTransitioningDelegate

extension LaunchViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.startingPoint = presenting.view.center
    transition.duration = 0.5
    transition.transitionMode = .present
    transition.bubbleColor = UIColor(white: 1.0, alpha: 0.9)
    return transition
  }
}

