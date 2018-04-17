//
//  ActivitySegment.swift
//
//  Created by Florian Rath on 27.08.17
//  Copyright (c) Codepool GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON


public struct ActivitySegment: Segment {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let startAddress2 = "start_address2"
    static let endAddress2 = "end_address2"
    static let timeZoneId = "time_zone_id"
    static let travelers = "travelers"
    static let source = "source"
    static let activityName = "activity_name"
    static let startCityName = "start_city_name"
    static let startDatetime = "start_datetime"
    static let type = "type"
    static let lastName = "last_name"
    static let startCountry = "start_country"
    static let currency = "currency"
    static let endAdminCode = "end_admin_code"
    static let startPostalCode = "start_postal_code"
    static let endName = "end_name"
    static let startAddress1 = "start_address1"
    static let endCityName = "end_city_name"
    static let endLat = "end_lat"
    static let startAdminCode = "start_admin_code"
    static let endLon = "end_lon"
    static let price = "price"
    static let endPostalCode = "end_postal_code"
    static let activityType = "activity_type"
    static let status = "status"
    static let endCountry = "end_country"
    static let created = "created"
    static let firstName = "first_name"
    static let endAddress1 = "end_address1"
    static let confirmationNo = "confirmation_no"
    static let endDatetime = "end_datetime"
    static let startLon = "start_lon"
    static let startLat = "start_lat"
    static let priceDetails = "price_details"
    static let startName = "start_name"
  }

  // MARK: Properties
    
    public var startAddress2: String?
    public var endAddress2: String?
  public var timeZoneId: String?
  public var travelers: [Travelers]?
  public var source: String?
  public var activityName: String?
  public var startCityName: String?
  public var startDatetime: String?
  public var type: String?
  public var lastName: String?
  public var startCountry: String?
  public var currency: String?
  public var endAdminCode: String?
  public var startPostalCode: String?
  public var endName: String?
  public var startAddress1: String?
  public var endCityName: String?
  public var endLat: String?
  public var startAdminCode: String?
  public var endLon: String?
  public var price: String?
  public var endPostalCode: String?
  public var activityType: String?
  public var status: String?
  public var endCountry: String?
  public var created: String?
  public var firstName: String?
  public var endAddress1: String?
  public var confirmationNo: String?
  public var endDatetime: String?
  public var startLon: String?
  public var startLat: String?
  public var priceDetails: [PriceDetails]?
  public var startName: String?

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
    startAddress2 = json[SerializationKeys.startAddress2].string
    endAddress2 = json[SerializationKeys.endAddress2].string
    timeZoneId = json[SerializationKeys.timeZoneId].string
    if let items = json[SerializationKeys.travelers].array { travelers = items.map { Travelers(json: $0) } }
    source = json[SerializationKeys.source].string
    activityName = json[SerializationKeys.activityName].string
    startCityName = json[SerializationKeys.startCityName].string
    startDatetime = json[SerializationKeys.startDatetime].string
    type = json[SerializationKeys.type].string
    lastName = json[SerializationKeys.lastName].string
    startCountry = json[SerializationKeys.startCountry].string
    currency = json[SerializationKeys.currency].string
    endAdminCode = json[SerializationKeys.endAdminCode].string
    startPostalCode = json[SerializationKeys.startPostalCode].string
    endName = json[SerializationKeys.endName].string
    startAddress1 = json[SerializationKeys.startAddress1].string
    endCityName = json[SerializationKeys.endCityName].string
    endLat = json[SerializationKeys.endLat].string
    startAdminCode = json[SerializationKeys.startAdminCode].string
    endLon = json[SerializationKeys.endLon].string
    price = json[SerializationKeys.price].string
    endPostalCode = json[SerializationKeys.endPostalCode].string
    activityType = json[SerializationKeys.activityType].string
    status = json[SerializationKeys.status].string
    endCountry = json[SerializationKeys.endCountry].string
    created = json[SerializationKeys.created].string
    firstName = json[SerializationKeys.firstName].string
    endAddress1 = json[SerializationKeys.endAddress1].string
    confirmationNo = json[SerializationKeys.confirmationNo].string
    endDatetime = json[SerializationKeys.endDatetime].string
    startLon = json[SerializationKeys.startLon].string
    startLat = json[SerializationKeys.startLat].string
    if let items = json[SerializationKeys.priceDetails].array { priceDetails = items.map { PriceDetails(json: $0) } }
    startName = json[SerializationKeys.startName].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = startAddress2 { dictionary[SerializationKeys.startAddress2] = value }
    if let value = endAddress2 { dictionary[SerializationKeys.endAddress2] = value }
    if let value = timeZoneId { dictionary[SerializationKeys.timeZoneId] = value }
    if let value = travelers { dictionary[SerializationKeys.travelers] = value.map { $0.dictionaryRepresentation() } }
    if let value = source { dictionary[SerializationKeys.source] = value }
    if let value = activityName { dictionary[SerializationKeys.activityName] = value }
    if let value = startCityName { dictionary[SerializationKeys.startCityName] = value }
    if let value = startDatetime { dictionary[SerializationKeys.startDatetime] = value }
    if let value = type { dictionary[SerializationKeys.type] = value }
    if let value = lastName { dictionary[SerializationKeys.lastName] = value }
    if let value = startCountry { dictionary[SerializationKeys.startCountry] = value }
    if let value = currency { dictionary[SerializationKeys.currency] = value }
    if let value = endAdminCode { dictionary[SerializationKeys.endAdminCode] = value }
    if let value = startPostalCode { dictionary[SerializationKeys.startPostalCode] = value }
    if let value = endName { dictionary[SerializationKeys.endName] = value }
    if let value = startAddress1 { dictionary[SerializationKeys.startAddress1] = value }
    if let value = endCityName { dictionary[SerializationKeys.endCityName] = value }
    if let value = endLat { dictionary[SerializationKeys.endLat] = value }
    if let value = startAdminCode { dictionary[SerializationKeys.startAdminCode] = value }
    if let value = endLon { dictionary[SerializationKeys.endLon] = value }
    if let value = price { dictionary[SerializationKeys.price] = value }
    if let value = endPostalCode { dictionary[SerializationKeys.endPostalCode] = value }
    if let value = activityType { dictionary[SerializationKeys.activityType] = value }
    if let value = status { dictionary[SerializationKeys.status] = value }
    if let value = endCountry { dictionary[SerializationKeys.endCountry] = value }
    if let value = created { dictionary[SerializationKeys.created] = value }
    if let value = firstName { dictionary[SerializationKeys.firstName] = value }
    if let value = endAddress1 { dictionary[SerializationKeys.endAddress1] = value }
    if let value = confirmationNo { dictionary[SerializationKeys.confirmationNo] = value }
    if let value = endDatetime { dictionary[SerializationKeys.endDatetime] = value }
    if let value = startLon { dictionary[SerializationKeys.startLon] = value }
    if let value = startLat { dictionary[SerializationKeys.startLat] = value }
    if let value = priceDetails { dictionary[SerializationKeys.priceDetails] = value.map { $0.dictionaryRepresentation() } }
    if let value = startName { dictionary[SerializationKeys.startName] = value }
    return dictionary
  }
    
    // MARK: Public
    
    public var userFacingStartDateString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: startDatetime) else {
            return nil
        }
        
        return tuple.0
    }
    
    public var userFacingStartTimeString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: startDatetime) else {
            return nil
        }
        
        return tuple.1
    }
    
    public var userFacingEndDateString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: endDatetime) else {
            return nil
        }
        
        return tuple.0
    }
    
    public var userFacingEndTimeString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: endDatetime) else {
            return nil
        }
        
        return tuple.1
    }

}


// MARK: Equatable
extension ActivitySegment: Equatable {}

public func ==(lhs: ActivitySegment, rhs: ActivitySegment) -> Bool {
    return NSDictionary(dictionary: lhs.dictionaryRepresentation()).isEqual(to: rhs.dictionaryRepresentation())
}
