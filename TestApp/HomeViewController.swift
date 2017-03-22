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

/// Mechanism for keeping track of region changes in map.
fileprivate enum MapState: Equatable {
  /// Nothing has been taken on.
  case none
  /// User has manually dragged the map.
  case dragging
  /// User tracking mode has been set to .followWithHeading.
  case following
  /// A route has been drawn on the map for selected placemark.
  case routing(Placemark)
  /// Camera properties have been updated on the map.
  case positioning
  /// Zoom scale of the map has been changed programmatically.
  case zooming
}

fileprivate func ==(lhs: MapState, rhs: MapState) -> Bool {
  switch (lhs, rhs) {
  case (.following, .following):
    return true
  case (.none, .none):
    return true
  case (.dragging, .dragging):
    return true
  case (.zooming, .zooming):
    return true
  case (.positioning, .positioning):
    return true
  case (let .routing(lp), let .routing(rp)):
    return lp == rp
  default:
    return false
  }
}

class HomeViewController: ViewController {
  
  /// The MKMapView instance showing nearby places as well as user's location.
  fileprivate(set) var mapView: MKMapView!
  
  /// Disposable holding the subscription observing the current MKDirections request.
  fileprivate var directions: Disposable?
  
  /// Activity indicator that observes directions request.
  fileprivate let directionsActivity = ActivityIndicator()
  
  /// Currently selected placemark whose route has been drawn.
  fileprivate(set) var selectedPlacemark: Placemark?
  
  /// An enum carrying information regarding last action taken on the map.
  fileprivate var mapState: MapState = .none
  
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
      mapView.edges == inset(view.edges, 0.0)
    })
    setTranslatesAutoresizingMaskIntoConstraintsIfRequired()
    
    controllerWasPresented.drive(onNext: { [unowned self] in
      // We register to Rx sequences right after view controller
      // has been presented.
      self.setupRx()
    })
      .addDisposableTo(rx_disposeBag)
  }
  
  /**
   Defines Rx subscriptions observing location changes generated
   by the GeolocationService class.
   
   Subscriptions may connect to backend server as a result of
   updates on user's location for fetching nearby places.
   */
  private func setupRxForLocationServices() {
    
  }
  
  /**
   Defines Rx subscriptions observing all delegate callbacks generated
   by map's delegate.
   
   Subscriptions may connect to backend server for fetching campaigns of
   the selected placemark.
   */
  private func setupRxForMapView() {
  }
  
  private func setupRx() {
    // Reachability
    
    $.reachabilityService?.reachability.bindTo(rx.reachability)
      .addDisposableTo(rx_disposeBag)
    
    // Notifications
    
    $.notificationService.authorization.drive(rx.notifications)
      .addDisposableTo(rx_disposeBag)
    
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
  
  var showPlacemarks: UIBindingObserver<Base, PlacemarkResponse> {
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
      
      if controller.mapState == .following {
        return
      }
      controller.mapState = .zooming
      controller.mapView.zoomToFitAllAnnotations(animated: true)
    }
  }
  
  var waitOnPlacemarks: UIBindingObserver<Base, Bool> {
    return UIBindingObserver(UIElement: base) { controller, waiting in
      if waiting {
        var config = Messages.bottom.defaultConfig
        
        config.backgroundColor = R.blackTextColor
        config.foregroundColor = R.whiteTextColor
        config.message = "placemarks-message".localized
        config.identifier = "placemarks-message-view"
        
        Messages.bottom.show(config: config)
      }
      else {
        Messages.bottom.hide(identifier: "placemarks-message-view")
      }
    }
  }
  
  var waitOnRoute: UIBindingObserver<Base, Bool> {
    return UIBindingObserver(UIElement: base) { controller, waiting in
      if waiting {
        var config = Messages.bottom.defaultConfig
        
        config.backgroundColor = R.blackTextColor
        config.foregroundColor = R.whiteTextColor
        config.message = "route-message".localized
        config.identifier = "route-message-view"
        
        Messages.bottom.show(config: config)
      }
      else {
        Messages.bottom.hide(identifier: "route-message-view")
      }
    }
  }
  
  var drawRoute: UIBindingObserver<Base, MKDirectionsResult> {
    return UIBindingObserver(UIElement: base) { controller, result in
      switch result {
      case .success(let placemark, let routes):
        controller.selectedPlacemark = placemark
        
        controller.mapView.removeOverlays(ofType: MKPolyline.self)
        controller.mapView.removeOverlays(ofType: PlacemarkRadar.self)
        
        for route in routes {
          controller.mapView.add(route.polyline, level: .aboveRoads)
        }
        controller.mapView.add(placemark.radar, level: .aboveRoads)
        controller.mapState = .routing(placemark)
        controller.mapView.zoomToFit(coordinates: placemark.coordinate, animated: true)
        
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
  
  var mapState: UIBindingObserver<Base, MapState> {
    return UIBindingObserver(UIElement: base) { controller, mapState in
      controller.mapState = mapState
    }
  }
}

extension HomeViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}

