//
//  String+Additions.swift
//  TestApp
//
//  Created by Ozgur on 19/01/2017.
//  Copyright © 2017 Ozgur. All rights reserved.
//

import Foundation

extension String {
  
  static let Empty: String = ""
  
  /// Returns the full range of string using length of it.
  public var fullRange: NSRange {
    return NSRange(location: 0, length: length)
  }
  
  /// Returns the length of string.
  var length: Int {
    return self.characters.count
  }
  
  /// Returns the first character of string if any.
  var first: String? {
    return isEmpty ? nil: self[0]
  }
  
  /// Returns the last character of string if any.
  var last: String? {
    return isEmpty ? nil: self[(length > 0 ? length : 1) - 1]
  }
  
  /// Returns NSString representation of string.
  var ns: NSString {
    return self as NSString
  }
  
  var localized: String {
    return NSLocalizedString(self)
  }
  
  /// Gets the character in given index as a string object.
  ///
  /// - Parameter index: Index to find the character.
  subscript(index: Int) -> String? {
    if let char = Array(characters).get(index) {
      return String(char)
    }
    return nil
  }
  
  func trimmedLeft(characterSet set: CharacterSet = CharacterSet.whitespacesAndNewlines) -> String {
    if let range = rangeOfCharacter(from: set.inverted) {
      return self[range.lowerBound..<endIndex]
    }
    return String.Empty
  }
  
  func trimmedRight(characterSet set: CharacterSet = CharacterSet.whitespacesAndNewlines) -> String {
    if let range = rangeOfCharacter(from: set.inverted, options: NSString.CompareOptions.backwards) {
      return self[startIndex..<range.upperBound]
    }
    return String.Empty
  }
  
  func trimmed() -> String {
    return trimmedLeft().trimmedRight()
  }
  
  var URLEscaped: String {
    return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
  }
}
