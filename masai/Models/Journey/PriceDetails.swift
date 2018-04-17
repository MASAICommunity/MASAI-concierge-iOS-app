//
//  PriceDetails.swift
//
//  Created by Florian Rath on 27.08.17
//  Copyright (c) Codepool GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON


public struct PriceDetails {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let name = "name"
    static let value = "value"
    static let type = "type"
    static let units = "units"
  }

  // MARK: Properties
  public var name: String?
  public var value: String?
  public var type: String?
  public var units: String?

  // MARK: SwiftyJSON Initializers
  /// Initiates the instance based on the object.
  ///
  /// - parameter object: The object of either Dictionary or Array kind that was passed.
  /// - returns: An initialized instance of the class.
  public init(object: Any) {
    self.init(json: JSON(object))
  }

  /// Initiates the instance based on the JSON that was passed.
  ///
  /// - parameter json: JSON object from SwiftyJSON.
  public init(json: JSON) {
    name = json[SerializationKeys.name].string
    value = json[SerializationKeys.value].string
    type = json[SerializationKeys.type].string
    units = json[SerializationKeys.units].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = name { dictionary[SerializationKeys.name] = value }
    if let value = value { dictionary[SerializationKeys.value] = value }
    if let value = type { dictionary[SerializationKeys.type] = value }
    if let value = units { dictionary[SerializationKeys.units] = value }
    return dictionary
  }

}
