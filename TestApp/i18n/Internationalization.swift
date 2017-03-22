//
//  Internationalization.swift
//  TestApp
//
//  Created by Ozgur Vatansever on 11/18/16.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import Swifternalization

/**
 Returns a localized string, using the main bundle if one is not specified.
 Calls `NSLocalizedString:comment` with empty `comment` value internally.
 
 - parameter key:      A key to which localized string is assigned

 - returns: localized string if found, otherwise `key` is returned.
 */
public func NSLocalizedString(_ key: String) -> String {
  return NSLocalizedString(key, comment: "")
}

// Alias for NSLocalizedString(_ key:) function.
public func localize(_ key: String) -> String {
  return NSLocalizedString(key)
}

/**
 Returns a localized string, using the main bundle if one is not specified.
 
 - parameter key:      A key to which localized string is assigned
 - parameter args:     Variable arguments
 
 - returns: localized string if found, otherwise `key` is returned.
 */
func NSLocalizedFormatString(_ key: String, _ args: CVarArg...) -> String {
  return withVaList(args) { (arguments) -> String in
    return NSString(format: NSLocalizedString(key), arguments: arguments) as String
  }
}

/**
 Returns the localized version of the given string with respect to pluralization value.
 Calls `Swifternalization.localizedString:intValue` internally.
 
 - parameter key:      A key to which localized string is assigned
 - parameter intValue: A int for determining pluralized version of the string
 
 - returns: localized string if found, otherwise `key` is returned.
 */
public func NSLocalizedString(_ key: String, intValue: Int) -> String {
  return String(format: Swifternalization.localizedString(key, intValue: intValue), intValue)
}
