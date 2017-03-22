//
//  PermissionService.swift
//  TestApp
//
//  Created by Ozgur on 18/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import PermissionScope
import RxCocoa
import RxSwift

final class PermissionService {
  
  static let shared = PermissionService()
    
  func prompt() -> Driver<[PermissionResult]> {
    return Observable<[PermissionResult]>.create ({ [unowned self]
      observer in
      let permissions = self.createPermissionsWindow()
      
      permissions.getResultsForConfig { results in
        if results.never ({ $0.status == .unknown }) {
          observer.on(.next(results))
          observer.on(.completed)
        }
        else {
          permissions.show({ finished, results in
            if results.any ({ $0.status == .unknown }) {
              return
            }
            observer.on(.next(results))
            observer.on(.completed)
          })
        }
      }
      return Disposables.create {
        DispatchQueue.main.asyncAfter(
          deadline: .now() + 0.5, execute: permissions.hide
        )
      }
    })
      .asDriver(onErrorJustReturn: [])
  }
  
  private func createPermissionsWindow() -> PermissionScope {
    let permissions = PermissionScope(backgroundTapCancels: false)
    permissions.contentView.backgroundColor = R.whiteTextColor
    
    permissions.headerLabel.font = R.defaultFont(ofSize: 16, heavy: true)
    permissions.headerLabel.textColor = R.blackTextColor
    
    permissions.bodyLabel.font = R.defaultFont(ofSize: 15)
    permissions.bodyLabel.textColor = R.blackTextColor
    
    permissions.buttonFont = R.defaultFont(ofSize: 15, heavy: true)
    permissions.labelFont = R.defaultFont(ofSize: 12)
    permissions.permissionLabelColor = R.blackTextColor
    
    permissions.unauthorizedButtonColor = R.failureColor
    permissions.authorizedButtonColor = R.successColor
    permissions.closeButton.isHidden = true
    
    permissions.addPermission(
      LocationAlwaysPermission(), message: localize("location-permission-text")
    )
    permissions.addPermission(
      NotificationsPermission(), message: localize("notification-permission-text")
    )
    return permissions
  }
}
