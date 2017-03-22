//
//  Messages.swift
//  TestApp
//
//  Created by Ozgur on 24/02/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import SwiftMessages

typealias MessageTheme = Theme // for not importing SwiftMessages everywhere.

struct Messages {
  
  static let top = Messages(presentationStyle: .top)
  static let bottom = Messages(presentationStyle: .bottom)
  
  let defaultConfig: Config
  private let messenger: SwiftMessages

  private init(presentationStyle: SwiftMessages.PresentationStyle) {
    messenger = SwiftMessages()
    defaultConfig = Config(presentationStyle: presentationStyle, theme: .info)
  }
  
  func show(config: Config) {
    let view = MessageView.viewFromNib(layout: config.layout)
    
    if let identifier = config.identifier {
      view.id = identifier
    }
    if let backgroundColor = config.backgroundColor,
      let foregroundColor = config.foregroundColor {
      view.configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor)
    }
    else {
      view.configureTheme(config.theme, iconStyle: .default)
    }
    view.configureDropShadow()
    view.configureContent(
      title: config.title, body: config.message, iconImage: nil, iconText: nil, buttonImage: nil,
      buttonTitle: config.buttonTitle, buttonTapHandler:  { _ in self.messenger.hide() }
    )
    if let titleFont = config.titleFont {
      view.titleLabel?.font = titleFont
    }
    if let messageFont = config.messageFont {
      view.bodyLabel?.font = messageFont
    }
    if let buttonFont = config.buttonFont {
      view.button?.titleLabel?.font = buttonFont
    }
    view.button?.isHidden = config.buttonTitle?.isEmpty ?? true
    view.tapHandler = { view in
      self.messenger.hide()
    }
    
    var swConfig = messenger.defaultConfig
    swConfig.presentationContext = config.presentationContext
    swConfig.presentationStyle = config.presentationStyle
    swConfig.preferredStatusBarStyle = .default

    swConfig.interactiveHide = true
    swConfig.duration = config.swDuration
    swConfig.preferredStatusBarStyle = .default
    
    if config.dim {
      swConfig.dimMode = .gray(interactive: true)
    }
    messenger.show(config: swConfig, view: view)
  }
  
  func hide(identifier: String? = nil) {
    if let identifier = identifier {
      messenger.hide(id: identifier)
    } else {
      messenger.hideAll()
    }
  }
  
  struct Config {
    var layout: MessageView.Layout = .StatusLine
    var presentationContext: SwiftMessages.PresentationContext
    var theme: MessageTheme
    var title: String? = nil
    var message: String? = nil
    var buttonTitle: String? = nil
    var identifier: String? = nil
    var dim: Bool = false
    var titleFont: UIFont?
    var messageFont: UIFont?
    var buttonFont: UIFont?
    var backgroundColor: UIColor?
    var foregroundColor: UIColor?
    
    fileprivate var presentationStyle: SwiftMessages.PresentationStyle
    fileprivate var swDuration: SwiftMessages.Duration = .forever

    var duration: TimeInterval = 0 {
      didSet {
        if duration > 0 {
          swDuration = .seconds(seconds: duration)
        } else {
          swDuration = .forever
        }
      }
    }
    
    private mutating func setDuration(_ duration: TimeInterval) {
      self.duration = duration
    }
    
    fileprivate init(presentationStyle: SwiftMessages.PresentationStyle, theme: MessageTheme) {
      self.presentationContext = .window(windowLevel: UIWindowLevelNormal)
      self.presentationStyle = presentationStyle
      self.theme = theme
      self.titleFont = R.boldFont(ofSize: 12.0)
      self.messageFont = R.mediumFont(ofSize: 10.0)
      self.buttonFont = R.mediumFont(ofSize: 12.0)
      self.setDuration(0)
    }
  }
}
