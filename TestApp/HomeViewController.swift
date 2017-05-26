//
//  HomeViewController.swift
//  TestApp
//
//  Created by Ozgur on 16/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import Cartography
import GoogleMaps
import MapKit
import RxCocoa
import RxGesture
import RxSwift
import UIKit

/// An enum for keeping track of region changes in map.
//private enum MapState: Equatable {
//  
//  /// Nothing has been taken on.
//  case none
//  
//  /// User is manually dragging the map.
//  case dragging
//  
//  /// User tracking is in follow mode. True if heading is on.
//  case following(Bool)
//  
//  /// A route has been drawn on the map for selected placemark.
//  case routing(Placemark)
//  
//  /// Whenever map has been zoomed in or out.
//  case zooming
//}

//private func ==(lhs: MapState, rhs: MapState) -> Bool {
//  switch (lhs, rhs) {
//  case (.following(let lf), .following(let rf)):
//    return lf == rf
//  case (.none, .none):
//    return true
//  case (.dragging, .dragging):
//    return true
//  case (.zooming, .zooming):
//    return true
//  case (let .routing(lp), let .routing(rp)):
//    return lp == rp
//  default:
//    return false
//  }
//}


class HomeViewController: ViewController {
  
  /// Map view showing all placemarks as well as user.
  var mapView: GMSMapView! {
    return isViewLoaded ? (view as! GMSMapView) : nil
  }
  
  /// Disposable for subscription observing the current MKDirections request.
  fileprivate var directions: Disposable?
  
  /// Activity indicator observing current directions request.
  fileprivate let directionsActivity = ActivityIndicator()
  
  /// Selected placemark by user in the map.
  fileprivate(set) var placemark: Placemark?
  
  /// Added placemarks to the map.
  fileprivate(set) var placemarks = [Placemark]()
  
  private func configureUI() {
    extendedLayoutIncludesOpaqueBars = true
    
    mapView.isTrafficEnabled = true
    mapView.setMinZoom(5, maxZoom: mapView.maxZoom)
    mapView.mapStyle = GMSMapStyle.from(style: "Silver")
    mapView.mapType = GMSMapViewType.normal
    mapView.settings.compassButton = false
    mapView.settings.setAllGesturesEnabled(true)
    mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
    mapView.settings.compassButton = true
    mapView.settings.indoorPicker = true
  }
  
  override func loadView() {
    let camera = GMSCameraPosition(withTarget: .center, zoom: 5)
    view = GMSMapView.map(withFrame: .zero, camera: camera)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    
    rx.viewDidAppear.take(1)
      .subscribe(onNext: { [unowned self] _ in
        // Produce Rx sequences when view becomes visible.
        self.setupRx()
      })
      .addDisposableTo(rx.disposeBag)
  }
  
  private func setupRxForLocationServices() {
    $.locationService.authorization.drive(mapView.rx.showUserLocation)
      .addDisposableTo(rx.disposeBag)
    
    let networkActivity = ActivityIndicator()
    
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
      .bindTo(rx.showPlacemarks)
      .addDisposableTo(rx.disposeBag)
    
    // Observe changes in API activity to act accordingly.
    networkActivity
      .filter { active in
        if active {
          // There is an ongoing network operation, so we check if 
          // there are any pins on the map. If there are, don't block the UI.
          return self.placemarks.isEmpty
        }
        else {
          return true // don't filter the stream, just unblock the UI.
        }
      }
      .drive(rx.isAnimating)
      .addDisposableTo(rx.disposeBag)
    
    networkActivity.asObservable()
      .map({ loading in
        var config = Messages.bottom.defaultConfig
        
        config.backgroundColor = R.blackTextColor
        config.foregroundColor = R.whiteTextColor
        config.message = "placemarks-message".localized
        config.identifier = "placemarks-message-view"
        
        return (loading, .bottom, config)
      })
      .bindTo(rx.message).addDisposableTo(rx.disposeBag)
  }
  
  private func setupRxForMapView() {
    
    mapView.rx.didTapAtCoordinate.subscribe { event in
      print(event)
    }.addDisposableTo(rx.disposeBag)
    
    mapView.rx.userLocation.filterNil()
      .take(1)
      .map { ($0, 13) } // zoom level is 13.
      .bindTo(rx.setCenter)
      .addDisposableTo(rx.disposeBag)
    
    //    // We show message when route is being calculated.
    //    directionsActivity
    //      .map { loading in
    //        var config = Messages.bottom.defaultConfig
    //
    //        config.backgroundColor = R.blackTextColor
    //        config.foregroundColor = R.whiteTextColor
    //        config.message = "route-message".localized
    //        config.identifier = "route-message-view"
    //
    //        return (loading, .bottom, config)
    //      }
    //      .asObservable()
    //      .bindTo(rx.message)
    //      .addDisposableTo(rx.disposeBag)
    
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
    
    setupRxForLocationServices()
    setupRxForMapView()
  }
}

fileprivate extension Reactive where Base: HomeViewController {
  
  var showPlacemarks: UIBindingObserver<Base, PlacemarkResponse> {
    return UIBindingObserver(UIElement: base) { controller, response in
      var toRemove = [Placemark]()
      var placemarks = response.placemarks
      
      controller.logger.debug("Received placemarks: \(placemarks)")
      
      controller.placemarks.forEach { marker in
        let (i, placemark) = placemarks.first(
          where: { $0.id == marker.id }
        )
        if let placemark = placemark {
          // Update campaigns so user will be notified.
          marker.campaigns.fill(withContentsOf: placemark.campaigns)
          placemarks.remove(at: i)
        }
        else {
          toRemove.append(marker)
        }
      }
      toRemove.forEach { placemark in
        placemark.marker.map = nil
        controller.placemarks.remove(placemark)
      }
      placemarks.forEach { placemark in
        placemark.marker.map = controller.mapView
        controller.placemarks.append(placemark)
      }
      controller.mapView.zoomToFit(markers: controller.placemarks, animated: true)
    }
  }
  
  var setCenter: UIBindingObserver<Base, (CLLocation, Float)> {
    return UIBindingObserver(UIElement: base) { controller, `where` in
      
      controller.mapView.camera = GMSCameraPosition(
        withTarget: `where`.0.coordinate, zoom: `where`.1
      )
    }
  }
}

//
//  var drawRoute: UIBindingObserver<Base, MKDirectionsResult> {
//    return UIBindingObserver(UIElement: base) { controller, result in
//      switch result {
//      case .success(let placemark, let routes):
//        controller.placemark = placemark
//
//        controller.mapView.removeOverlays(ofType: MKPolyline.self)
//        controller.mapView.removeOverlays(ofType: PlacemarkRadar.self)
//
//        var coordinates = [CLLocationCoordinate2D]()
//        coordinates.append(placemark.coordinate)
//
//        for route in routes {
//          controller.mapView.add(route.polyline, level: .aboveRoads)
//          coordinates.append(route.polyline.coordinate)
//        }
//        controller.mapView.add(placemark.radar, level: .aboveRoads)
//        controller.mapState = .routing(placemark)
//        controller.mapView.zoomToFit(coordinates: coordinates, animated: true)
//      case .failure:
//        Wireframe.presentAlert("route-request-failed".localized)
//      }
//    }
//  }
//
//  var showTrackerButton: UIBindingObserver<Base, Bool> {
//    return UIBindingObserver(UIElement: base) { controller, show in
//      switch show {
//      case true:
//        let trackerButton = MKUserTrackingBarButtonItem(mapView: controller.mapView)
//        controller.navigationItem.rightBarButtonItem = trackerButton
//      case false:
//        controller.navigationItem.rightBarButtonItem = nil
//      }
//    }
//  }
//
//  var setState: UIBindingObserver<Base, MapState> {
//    return UIBindingObserver(UIElement: base) { controller, mapState in
//      controller.mapState = mapState
//    }
//  }
//
//  var setRegion: UIBindingObserver<Base, MKCoordinateRegion> {
//    return UIBindingObserver(UIElement: base) { controller, region in
//      controller.mapState = .zooming
//      controller.mapView.setRegion(region, animated: true)
//    }
//  }
//
//  var zoomToFitPlacemark: UIBindingObserver<Base, Void> {
//    return UIBindingObserver(UIElement: base) { controller, _ in
//      guard let placemark = controller.placemark
//        else { return }
//
//      controller.mapState = .routing(placemark)
//      controller.mapView.zoomToFit(
//        coordinates: [placemark.coordinate], animated: true)
//    }
//  }
//}
//
