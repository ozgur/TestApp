//
//  HomeViewController.swift
//  TestApp
//
//  Created by Ozgur on 16/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import Cartography
import MapKit
import RxGesture
import RxSwift
import RxCocoa
import UIKit

/// An enum for keeping track of region changes in map.
private enum MapState: Equatable {
  
  /// Nothing has been taken on.
  case none
  
  /// User is manually dragging the map.
  case dragging
  
  /// User tracking is in follow mode. True if heading is on.
  case following(Bool)
  
  /// A route has been drawn on the map for selected placemark.
  case routing(Placemark)
  
  /// Whenever map has been zoomed in or out.
  case zooming
}

private func ==(lhs: MapState, rhs: MapState) -> Bool {
  switch (lhs, rhs) {
  case (.following(let lf), .following(let rf)):
    return lf == rf
  case (.none, .none):
    return true
  case (.dragging, .dragging):
    return true
  case (.zooming, .zooming):
    return true
  case (let .routing(lp), let .routing(rp)):
    return lp == rp
  default:
    return false
  }
}

/**
 Returns the corresponding map state for given user tracking mode.
 If not found, it returns `MapState.none`.
 
 - parameter mode: Current tracking mode of the map.
 - returns: corresponding map state value.
 */
private func MapStateFromTrackingMode(_ mode: MKUserTrackingMode) -> MapState {
  switch mode {
  case .follow:
    return .following(false)
  case .followWithHeading:
    return .following(true)
  default:
    return .none
  }
}

class HomeViewController: ViewController {
  
  /// The map displaying nearby places as pins as well as user's location.
  fileprivate(set) var mapView: MKMapView!
  
  /// Disposable for subscription observing the current MKDirections request.
  fileprivate var directions: Disposable?
  
  /// Activity indicator observing current directions request.
  fileprivate let directionsActivity = ActivityIndicator()
  
  /// Selected placemark by user.
  fileprivate(set) var placemark: Placemark?
  
  /// Returns true if there is any route drawn on the map for a placemark.
  fileprivate var hasRoute: Bool {
    return mapView.hasOverlays(ofType: MKPolyline.self)
  }
  
  /// Returns current tracking mode for the map.
  fileprivate var userTrackingMode: MKUserTrackingMode {
    return mapView.userTrackingMode
  }
  
  /// An enum carrying information regarding last action taken on the map.
  fileprivate var mapState: MapState = .none {
    didSet {
      logger.info("Map state: \(mapState)")
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    extendedLayoutIncludesOpaqueBars = true
    
    navigationBar?.backgroundColor = .clear
    navigationBar?.setBackgroundImage(UIImage(), for: .default)
    navigationBar?.shadowImage = UIImage()
    navigationBar?.isTranslucent = true
    
    mapView = MKMapView(frame: .zero, delegate: self)
    mapView.showsCompass = false
    view.addSubview(mapView)
    
    constrain(mapView, view, block: { mapView, view in
      mapView.size == view.size
      mapView.edges == view.edges
    })
    setTranslatesAutoresizingMaskIntoConstraintsIfRequired()
    
    controllerWasPresented.drive(onNext: { [unowned self] in
      // We register to Rx sequences right after view controller
      // has been presented.
      self.setupRx()
      
    })
      .addDisposableTo(rx.disposeBag)
  }
  
  private func setupRxForLocationServices() {
    
    // We show or hide tracker button with respect to GPS
    // permission status.
    $.locationService.authorization.drive(rx.showTrackerButton)
      .addDisposableTo(rx.disposeBag)
    
    // We show or hide user's location on map with respect to GPS
    // permission status.
    $.locationService.authorization.drive(mapView.rx.showUserLocation)
      .addDisposableTo(rx.disposeBag)
    
    let networkActivity = ActivityIndicator()
    
    // We center user's location on the map only once while waiting
    // for new placemarks.
    mapView.rx.didUpdateUserRegion
      .takeUntil(
        networkActivity.skip(1).filter { !$0 }.asObservable()
      )
      .take(1)
      .bindTo(rx.setRegion)
      .addDisposableTo(rx.disposeBag)
    
    
    // We go get placemarks around user when their location is
    // sent by GPS service.
    $.locationService.location.asObservable()
      .flatMap { location in
        API.shared.getPlacemarks(location: location)
          .trackActivity(networkActivity)
          .retryWhenReachable(.invalid, service: .shared)
      }
      .ignoreWhen { response in
        response == .invalid
      }
      .bindTo(rx.showAnnotations)
      .addDisposableTo(rx.disposeBag)
    
    
    // Observe changes in API activity to act accordingly.
    networkActivity
      .map({ loading in
        var config = Messages.bottom.defaultConfig
        
        config.backgroundColor = R.blackTextColor
        config.foregroundColor = R.whiteTextColor
        config.message = "placemarks-message".localized
        config.identifier = "placemarks-message-view"
        
        return (loading, .bottom, config)
      })
      .drive(rx.message).addDisposableTo(rx.disposeBag)
  }
  
  private func setupRxForMapView() {
    
    // We show message when route is being calculated.
    directionsActivity
      .map { loading in
        var config = Messages.bottom.defaultConfig
        
        config.backgroundColor = R.blackTextColor
        config.foregroundColor = R.whiteTextColor
        config.message = "route-message".localized
        config.identifier = "route-message-view"
        
        return (loading, .bottom, config)
      }
      .asObservable()
      .bindTo(rx.message)
      .addDisposableTo(rx.disposeBag)
    
    // We center user and zoom in when follow mode with
    // heading is on.
    // TODO: Not working correctly!!
    mapView.rx.didUpdateUserRegion.filter ({
      [unowned self] location in
      self.mapState == .following(true)
    })
      .bindTo(rx.setRegion).addDisposableTo(rx_disposeBag)
    
    // We update map state when user changes the tracking mode.
    mapView.rx.didChangeUserTrackingMode
      .map { (mode, animated) -> MapState in
        MapStateFromTrackingMode(mode)
      }
      .bindTo(rx.setState)
      .addDisposableTo(rx.disposeBag)
    
    // When tracking mode changes to .none by tapping the button,
    // animated is sent true so, when there is a route, we should
    // zoom in/out to cover it.
    mapView.rx.didChangeUserTrackingMode
      .filter ({ (mode, animated) -> Bool in
        mode == .none && animated
      })
      .mapToVoid()
      .filter ({ [unowned self] in
        self.hasRoute == true
      })
      .bindTo(rx.zoomToFitPlacemark)
      .addDisposableTo(rx_disposeBag)
    
    // Animate pin drops
    
    mapView.rx.didAddAnnotationViews.subscribe(onNext: {
      [unowned self] views in
      for (i, view) in views.enumerated() {
        guard let view = view as? PlacemarkAnnotationView
          else { continue }
        
        if view.animatesDrop {
          let point = MKMapPointForCoordinate(view.placemark.coordinate)
          
          if (MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
            
            let frame = view.frame
            view.frame.origin.y -= self.mapView.frame.height
            
            UIView.animate(withDuration: 0.9 , delay: Double(i) * 0.06,
                           options: .curveEaseInOut, animations: {
                            view.frame = frame
            }, completion: { finished in
              if finished {
                UIView.animate(withDuration: 0.05, animations: {
                  view.transform = CGAffineTransform(scaleX: 1.0, y: 0.8)
                }, completion: { finished in
                  if finished {
                    UIView.animate(
                      withDuration: 0.1, animations: view.transformToIdentity
                    )
                  }
                })
              }
            })
          }
        }
      }
    })
      .addDisposableTo(rx_disposeBag)
  }
  
  private func setupRxForGestures() {
    
    // Same configuration block is used for all gesture recognizers.
    let configuration: (UIGestureRecognizer) -> () = {
      [unowned self] recognizer in
      recognizer.delegate = self
    }
    
    // We change map state to .dragging when user manually drags the map.
    mapView.rx.panGesture(configuration: configuration)
      .when(.began, .changed)
      .mapTo(.dragging).bindTo(rx.setState)
      .addDisposableTo(rx.disposeBag)
    
    
    // We change map state to .zooming when user pinches or double
    // taps the map.
    let tapGesture = AnyGestureRecognizerFactory.tap(
      numberOfTapsRequired: 2, configuration: configuration
    )
    let pinchGesture = AnyGestureRecognizerFactory.pinch(
      configuration: configuration
    )
    
    mapView.rx.anyGesture(
      (tapGesture, when: [.recognized]),
      (pinchGesture, when: [.began, .changed])
      )
      .mapTo(.zooming).bindTo(rx.setState)
      .addDisposableTo(rx.disposeBag)
  }
  
  private func setupRx() {
    
    // We show an error message if network connection is gone.
    $.reachabilityService?.reachability.bindTo(rx.reachability)
      .addDisposableTo(rx.disposeBag)
    
    // We show a warning when notification permissions are denied.
    $.notificationService.authorization.drive(rx.notifications)
      .addDisposableTo(rx.disposeBag)
    
    // We show a warning when location permissions are denied.
    $.locationService.authorization.drive(rx.locations)
      .addDisposableTo(rx.disposeBag)
    
    setupRxForGestures()
    setupRxForLocationServices()
    setupRxForMapView()
  }
}

extension HomeViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let annotation = annotation as? Placemark
      else { return nil }
    var view = mapView.dequeueReusableAnnotationView(withIdentifier: "Placemark")
      as? PlacemarkAnnotationView
    if view == nil {
      view = PlacemarkAnnotationView(annotation: annotation, reuseIdentifier: "Placemark")
      view?.animatesDrop = true
    } else {
      view?.animatesDrop = false
    }
    view?.image = annotation.company?.thumbnail
    view?.canShowCallout = true
    view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    return view
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
               calloutAccessoryControlTapped control: UIControl) {
    
    guard let placemark = view.annotation as? Placemark
      else { return }
    
    directions?.dispose()
    directions = mapView.rx.routes(to: placemark, via: .any)
      .asDriver(onErrorJustReturn: .success(placemark, []))
      .trackActivity(directionsActivity)
      .bindTo(rx.drawRoute)
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    var renderer: MKOverlayPathRenderer!
    
    if let polyline = overlay as? MKPolyline {
      renderer = MKPolylineRenderer(overlay: polyline)
      renderer.strokeColor = R.routeColor
    }
    else if let circle = overlay as? MKCircle {
      renderer = MKCircleRenderer(circle: circle)
      renderer.fillColor = R.radarColor
    }
    return renderer
  }
}

fileprivate extension Reactive where Base: HomeViewController {
  
  var showAnnotations: UIBindingObserver<Base, PlacemarkResponse> {
    return UIBindingObserver(UIElement: base) { controller, response in
      var toRemove = [Placemark]()
      var placemarks = response.placemarks
      
      controller.mapView.annotations.forEach { annotation in
        guard let annotation = annotation as? Placemark
          else { return }
        
        let (i, placemark) = placemarks.first(
          where: { $0.id == annotation.id }
        )
        if let placemark = placemark {
          // Update campaigns so user will be notified.
          annotation.campaigns.fill(withContentsOf: placemark.campaigns)
          placemarks.remove(at: i)
        }
        else {
          toRemove.append(annotation)
        }
      }
      controller.mapView.removeAnnotations(toRemove)
      controller.logger.debug("Removed placemarks: \(toRemove)")
      
      controller.mapView.addAnnotations(placemarks)
      controller.logger.debug("Added placemarks: \(placemarks)")
      
      if controller.mapState == .following(true) {
        return
      }
      controller.mapState = .zooming
      controller.mapView.zoomToFitAllAnnotations(animated: true)
    }
  }
  
  var drawRoute: UIBindingObserver<Base, MKDirectionsResult> {
    return UIBindingObserver(UIElement: base) { controller, result in
      switch result {
      case .success(let placemark, let routes):
        controller.placemark = placemark
        
        controller.mapView.removeOverlays(ofType: MKPolyline.self)
        controller.mapView.removeOverlays(ofType: PlacemarkRadar.self)
        
        for route in routes {
          controller.mapView.add(route.polyline, level: .aboveRoads)
        }
        controller.mapView.add(placemark.radar, level: .aboveRoads)
        controller.mapState = .routing(placemark)
        controller.mapView.zoomToFit(coordinates: [placemark.coordinate], animated: true)
      case .failure:
        Wireframe.presentAlert("route-request-failed".localized)
      }
    }
  }
  
  var showTrackerButton: UIBindingObserver<Base, Bool> {
    return UIBindingObserver(UIElement: base) { controller, show in
      switch show {
      case true:
        let trackerButton = MKUserTrackingBarButtonItem(mapView: controller.mapView)
        controller.navigationItem.rightBarButtonItem = trackerButton
      case false:
        controller.navigationItem.rightBarButtonItem = nil
      }
    }
  }
  
  var setState: UIBindingObserver<Base, MapState> {
    return UIBindingObserver(UIElement: base) { controller, mapState in
      controller.mapState = mapState
    }
  }
  
  var setRegion: UIBindingObserver<Base, MKCoordinateRegion> {
    return UIBindingObserver(UIElement: base) { controller, region in
      controller.mapState = .zooming
      controller.mapView.setRegion(region, animated: true)
    }
  }
  
  var zoomToFitPlacemark: UIBindingObserver<Base, Void> {
    return UIBindingObserver(UIElement: base) { controller, _ in
      guard let placemark = controller.placemark
        else { return }
      
      controller.mapState = .routing(placemark)
      controller.mapView.zoomToFit(
        coordinates: [placemark.coordinate], animated: true)
    }
  }
}

extension HomeViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool
  {
    if let pinch = gestureRecognizer as? UIPinchGestureRecognizer,
      [.began, .changed, .ended, .failed].contains(pinch.state) {
      return (otherGestureRecognizer is UIPanGestureRecognizer) == false
    }
    else if let pinch = otherGestureRecognizer as? UIPinchGestureRecognizer,
      [.began, .changed, .ended, .failed].contains(pinch.state) {
      return (gestureRecognizer is UIPanGestureRecognizer) == false
    }
    return true
  }
}

