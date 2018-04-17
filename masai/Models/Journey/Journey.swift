//
//  Journey.swift
//
//  Created by Florian Rath on 27.08.17
//  Copyright (c) Codepool GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON


public struct Journey {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let segments = "segments"
    static let userId = "UserId"
    static let created = "created"
    static let journeyId = "JourneyId"
  }

  // MARK: Properties
  public var segments: [Segment]?
  public var userId: String?
  public var created: String?
  public var journeyId: String?

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
    if let items = json[SerializationKeys.segments].array { segments = items.flatMap { SegmentFactory.segment(from: $0) } }
    userId = json[SerializationKeys.userId].string
    created = json[SerializationKeys.created].string
    journeyId = json[SerializationKeys.journeyId].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = segments { dictionary[SerializationKeys.segments] = value.map { $0.dictionaryRepresentation() } }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = created { dictionary[SerializationKeys.created] = value }
    if let value = journeyId { dictionary[SerializationKeys.journeyId] = value }
    return dictionary
  }

}
