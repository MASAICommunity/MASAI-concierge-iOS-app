//
//  CarSegment.swift
//
//  Created by Florian Rath on 27.08.17
//  Copyright (c) Codepool GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON


public struct CarSegment: Segment {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let carDescription = "car_description"
    static let dropoffAddress2 = "dropoff_address2"
    static let pickupAddress2 = "pickup_address2"
    static let travelers = "travelers"
    static let dropoffAddress1 = "dropoff_address1"
    static let normalizedCarCompany = "normalized_car_company"
    static let source = "source"
    static let dropoffLon = "dropoff_lon"
    static let pickupTimeZoneId = "pickup_time_zone_id"
    static let pickupLat = "pickup_lat"
    static let pickupLon = "pickup_lon"
    static let type = "type"
    static let carType = "car_type"
    static let dropoffCityName = "dropoff_city_name"
    static let lastName = "last_name"
    static let currency = "currency"
    static let dropoffPostalCode = "dropoff_postal_code"
    static let pickupPostalCode = "pickup_postal_code"
    static let hoursOfOperation = "hours_of_operation"
    static let carCompany = "car_company"
    static let dropoffAdminCode = "dropoff_admin_code"
    static let pickupDatetime = "pickup_datetime"
    static let pickupCityName = "pickup_city_name"
    static let pickupAddress1 = "pickup_address1"
    static let dropoffTimeZoneId = "dropoff_time_zone_id"
    static let dropoffCountry = "dropoff_country"
    static let price = "price"
    static let status = "status"
    static let created = "created"
    static let dropoffLat = "dropoff_lat"
    static let firstName = "first_name"
    static let confirmationNo = "confirmation_no"
    static let pickupAdminCode = "pickup_admin_code"
    static let dropoffDatetime = "dropoff_datetime"
    static let pickupCountry = "pickup_country"
    static let priceDetails = "price_details"
  }

  // MARK: Properties
    public var carDescription: String?
    public var dropoffAddress2: String?
    public var pickupAddress2: String?
  public var travelers: [Travelers]?
  public var dropoffAddress1: String?
  public var normalizedCarCompany: String?
  public var source: String?
  public var dropoffLon: String?
  public var pickupTimeZoneId: String?
  public var pickupLat: String?
  public var pickupLon: String?
  public var type: String?
  public var carType: String?
  public var dropoffCityName: String?
  public var lastName: String?
  public var currency: String?
  public var dropoffPostalCode: String?
  public var pickupPostalCode: String?
  public var hoursOfOperation: String?
  public var carCompany: String?
  public var dropoffAdminCode: String?
  public var pickupDatetime: String?
  public var pickupCityName: String?
  public var pickupAddress1: String?
  public var dropoffTimeZoneId: String?
  public var dropoffCountry: String?
  public var price: String?
  public var status: String?
  public var created: String?
  public var dropoffLat: String?
  public var firstName: String?
  public var confirmationNo: String?
  public var pickupAdminCode: String?
  public var dropoffDatetime: String?
  public var pickupCountry: String?
  public var priceDetails: [PriceDetails]?

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
    if let items = json[SerializationKeys.travelers].array { travelers = items.map { Travelers(json: $0) } }
    carDescription = json[SerializationKeys.carDescription].string
    dropoffAddress2 = json[SerializationKeys.dropoffAddress2].string
    pickupAddress2 = json[SerializationKeys.pickupAddress2].string
    dropoffAddress1 = json[SerializationKeys.dropoffAddress1].string
    normalizedCarCompany = json[SerializationKeys.normalizedCarCompany].string
    source = json[SerializationKeys.source].string
    dropoffLon = json[SerializationKeys.dropoffLon].string
    pickupTimeZoneId = json[SerializationKeys.pickupTimeZoneId].string
    pickupLat = json[SerializationKeys.pickupLat].string
    pickupLon = json[SerializationKeys.pickupLon].string
    type = json[SerializationKeys.type].string
    carType = json[SerializationKeys.carType].string
    dropoffCityName = json[SerializationKeys.dropoffCityName].string
    lastName = json[SerializationKeys.lastName].string
    currency = json[SerializationKeys.currency].string
    dropoffPostalCode = json[SerializationKeys.dropoffPostalCode].string
    pickupPostalCode = json[SerializationKeys.pickupPostalCode].string
    hoursOfOperation = json[SerializationKeys.hoursOfOperation].string
    carCompany = json[SerializationKeys.carCompany].string
    dropoffAdminCode = json[SerializationKeys.dropoffAdminCode].string
    pickupDatetime = json[SerializationKeys.pickupDatetime].string
    pickupCityName = json[SerializationKeys.pickupCityName].string
    pickupAddress1 = json[SerializationKeys.pickupAddress1].string
    dropoffTimeZoneId = json[SerializationKeys.dropoffTimeZoneId].string
    dropoffCountry = json[SerializationKeys.dropoffCountry].string
    price = json[SerializationKeys.price].string
    status = json[SerializationKeys.status].string
    created = json[SerializationKeys.created].string
    dropoffLat = json[SerializationKeys.dropoffLat].string
    firstName = json[SerializationKeys.firstName].string
    confirmationNo = json[SerializationKeys.confirmationNo].string
    pickupAdminCode = json[SerializationKeys.pickupAdminCode].string
    dropoffDatetime = json[SerializationKeys.dropoffDatetime].string
    pickupCountry = json[SerializationKeys.pickupCountry].string
    if let items = json[SerializationKeys.priceDetails].array { priceDetails = items.map { PriceDetails(json: $0) } }
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = carDescription { dictionary[SerializationKeys.carDescription] = value }
    if let value = dropoffAddress2 { dictionary[SerializationKeys.dropoffAddress2] = value }
    if let value = pickupAddress2 { dictionary[SerializationKeys.pickupAddress2] = value }
    if let value = travelers { dictionary[SerializationKeys.travelers] = value.map { $0.dictionaryRepresentation() } }
    if let value = dropoffAddress1 { dictionary[SerializationKeys.dropoffAddress1] = value }
    if let value = normalizedCarCompany { dictionary[SerializationKeys.normalizedCarCompany] = value }
    if let value = source { dictionary[SerializationKeys.source] = value }
    if let value = dropoffLon { dictionary[SerializationKeys.dropoffLon] = value }
    if let value = pickupTimeZoneId { dictionary[SerializationKeys.pickupTimeZoneId] = value }
    if let value = pickupLat { dictionary[SerializationKeys.pickupLat] = value }
    if let value = pickupLon { dictionary[SerializationKeys.pickupLon] = value }
    if let value = type { dictionary[SerializationKeys.type] = value }
    if let value = carType { dictionary[SerializationKeys.carType] = value }
    if let value = dropoffCityName { dictionary[SerializationKeys.dropoffCityName] = value }
    if let value = lastName { dictionary[SerializationKeys.lastName] = value }
    if let value = currency { dictionary[SerializationKeys.currency] = value }
    if let value = dropoffPostalCode { dictionary[SerializationKeys.dropoffPostalCode] = value }
    if let value = pickupPostalCode { dictionary[SerializationKeys.pickupPostalCode] = value }
    if let value = hoursOfOperation { dictionary[SerializationKeys.hoursOfOperation] = value }
    if let value = carCompany { dictionary[SerializationKeys.carCompany] = value }
    if let value = dropoffAdminCode { dictionary[SerializationKeys.dropoffAdminCode] = value }
    if let value = pickupDatetime { dictionary[SerializationKeys.pickupDatetime] = value }
    if let value = pickupCityName { dictionary[SerializationKeys.pickupCityName] = value }
    if let value = pickupAddress1 { dictionary[SerializationKeys.pickupAddress1] = value }
    if let value = dropoffTimeZoneId { dictionary[SerializationKeys.dropoffTimeZoneId] = value }
    if let value = dropoffCountry { dictionary[SerializationKeys.dropoffCountry] = value }
    if let value = price { dictionary[SerializationKeys.price] = value }
    if let value = status { dictionary[SerializationKeys.status] = value }
    if let value = created { dictionary[SerializationKeys.created] = value }
    if let value = dropoffLat { dictionary[SerializationKeys.dropoffLat] = value }
    if let value = firstName { dictionary[SerializationKeys.firstName] = value }
    if let value = confirmationNo { dictionary[SerializationKeys.confirmationNo] = value }
    if let value = pickupAdminCode { dictionary[SerializationKeys.pickupAdminCode] = value }
    if let value = dropoffDatetime { dictionary[SerializationKeys.dropoffDatetime] = value }
    if let value = pickupCountry { dictionary[SerializationKeys.pickupCountry] = value }
    if let value = priceDetails { dictionary[SerializationKeys.priceDetails] = value.map { $0.dictionaryRepresentation() } }
    return dictionary
  }
    
    // MARK: Public
    
    public var userFacingStartDateString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: pickupDatetime) else {
            return nil
        }
        
        return tuple.0
    }
    
    public var userFacingStartTimeString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: pickupDatetime) else {
            return nil
        }
        
        return tuple.1
    }
    
    public var userFacingEndDateString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: dropoffDatetime) else {
            return nil
        }
        
        return tuple.0
    }
    
    public var userFacingEndTimeString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: dropoffDatetime) else {
            return nil
        }
        
        return tuple.1
    }

}


// MARK: Equatable
extension CarSegment: Equatable {}

public func ==(lhs: CarSegment, rhs: CarSegment) -> Bool {
    return NSDictionary(dictionary: lhs.dictionaryRepresentation()).isEqual(to: rhs.dictionaryRepresentation())
}
