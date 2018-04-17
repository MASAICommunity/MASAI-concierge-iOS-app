//
//  HotelSegment.swift
//
//  Created by Florian Rath on 27.08.17
//  Copyright (c) Codepool GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON


public struct HotelSegment: Segment {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let address2 = "address2"
    static let rateDescription = "rate_description"
    static let roomDescription = "room_description"
    static let roomType = "room_type"
    static let travelers = "travelers"
    static let timeZoneId = "time_zone_id"
    static let address1 = "address1"
    static let source = "source"
    static let cityName = "city_name"
    static let cancellationPolicy = "cancellation_policy"
    static let type = "type"
    static let checkinDate = "checkin_date"
    static let lastName = "last_name"
    static let currency = "currency"
    static let lon = "lon"
    static let hotelName = "hotel_name"
    static let numberOfRooms = "number_of_rooms"
    static let postalCode = "postal_code"
    static let adminCode = "admin_code"
    static let lat = "lat"
    static let price = "price"
    static let status = "status"
    static let checkoutDate = "checkout_date"
    static let created = "created"
    static let firstName = "first_name"
    static let confirmationNo = "confirmation_no"
    static let priceDetails = "price_details"
    static let country = "country"
  }

  // MARK: Properties
    public var address2: String?
    public var rateDescription: String?
    public var roomDescription: String?
    public var roomType: String?
  public var travelers: [Travelers]?
  public var timeZoneId: String?
  public var address1: String?
  public var source: String?
  public var cityName: String?
  public var cancellationPolicy: String?
  public var type: String?
  public var checkinDate: String?
  public var lastName: String?
  public var currency: String?
  public var lon: String?
  public var hotelName: String?
  public var numberOfRooms: String?
  public var postalCode: String?
  public var adminCode: String?
  public var lat: String?
  public var price: String?
  public var status: String?
  public var checkoutDate: String?
  public var created: String?
  public var firstName: String?
  public var confirmationNo: String?
  public var priceDetails: [PriceDetails]?
  public var country: String?

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
    address2 = json[SerializationKeys.address2].string
    rateDescription = json[SerializationKeys.rateDescription].string
    roomDescription = json[SerializationKeys.roomDescription].string
    roomType = json[SerializationKeys.roomType].string
    timeZoneId = json[SerializationKeys.timeZoneId].string
    address1 = json[SerializationKeys.address1].string
    source = json[SerializationKeys.source].string
    cityName = json[SerializationKeys.cityName].string
    cancellationPolicy = json[SerializationKeys.cancellationPolicy].string
    type = json[SerializationKeys.type].string
    checkinDate = json[SerializationKeys.checkinDate].string
    lastName = json[SerializationKeys.lastName].string
    currency = json[SerializationKeys.currency].string
    lon = json[SerializationKeys.lon].string
    hotelName = json[SerializationKeys.hotelName].string
    numberOfRooms = json[SerializationKeys.numberOfRooms].string
    postalCode = json[SerializationKeys.postalCode].string
    adminCode = json[SerializationKeys.adminCode].string
    lat = json[SerializationKeys.lat].string
    price = json[SerializationKeys.price].string
    status = json[SerializationKeys.status].string
    checkoutDate = json[SerializationKeys.checkoutDate].string
    created = json[SerializationKeys.created].string
    firstName = json[SerializationKeys.firstName].string
    confirmationNo = json[SerializationKeys.confirmationNo].string
    if let items = json[SerializationKeys.priceDetails].array { priceDetails = items.map { PriceDetails(json: $0) } }
    country = json[SerializationKeys.country].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = address2 { dictionary[SerializationKeys.address2] = value }
    if let value = rateDescription { dictionary[SerializationKeys.rateDescription] = value }
    if let value = roomDescription { dictionary[SerializationKeys.roomDescription] = value }
    if let value = roomType { dictionary[SerializationKeys.roomType] = value }
    if let value = travelers { dictionary[SerializationKeys.travelers] = value.map { $0.dictionaryRepresentation() } }
    if let value = timeZoneId { dictionary[SerializationKeys.timeZoneId] = value }
    if let value = address1 { dictionary[SerializationKeys.address1] = value }
    if let value = source { dictionary[SerializationKeys.source] = value }
    if let value = cityName { dictionary[SerializationKeys.cityName] = value }
    if let value = cancellationPolicy { dictionary[SerializationKeys.cancellationPolicy] = value }
    if let value = type { dictionary[SerializationKeys.type] = value }
    if let value = checkinDate { dictionary[SerializationKeys.checkinDate] = value }
    if let value = lastName { dictionary[SerializationKeys.lastName] = value }
    if let value = currency { dictionary[SerializationKeys.currency] = value }
    if let value = lon { dictionary[SerializationKeys.lon] = value }
    if let value = hotelName { dictionary[SerializationKeys.hotelName] = value }
    if let value = numberOfRooms { dictionary[SerializationKeys.numberOfRooms] = value }
    if let value = postalCode { dictionary[SerializationKeys.postalCode] = value }
    if let value = adminCode { dictionary[SerializationKeys.adminCode] = value }
    if let value = lat { dictionary[SerializationKeys.lat] = value }
    if let value = price { dictionary[SerializationKeys.price] = value }
    if let value = status { dictionary[SerializationKeys.status] = value }
    if let value = checkoutDate { dictionary[SerializationKeys.checkoutDate] = value }
    if let value = created { dictionary[SerializationKeys.created] = value }
    if let value = firstName { dictionary[SerializationKeys.firstName] = value }
    if let value = confirmationNo { dictionary[SerializationKeys.confirmationNo] = value }
    if let value = priceDetails { dictionary[SerializationKeys.priceDetails] = value.map { $0.dictionaryRepresentation() } }
    if let value = country { dictionary[SerializationKeys.country] = value }
    return dictionary
  }
    
    // MARK: Public
    
    public var userFacingStartDateString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: checkinDate) else {
            return nil
        }
        
        return tuple.0
    }
    
    public var userFacingStartTimeString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: checkinDate) else {
            return nil
        }
        
        return tuple.1
    }
    
    public var userFacingEndDateString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: checkoutDate) else {
            return nil
        }
        
        return tuple.0
    }
    
    public var userFacingEndTimeString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: checkoutDate) else {
            return nil
        }
        
        return tuple.1
    }

}


// MARK: Equatable
extension HotelSegment: Equatable {}

public func ==(lhs: HotelSegment, rhs: HotelSegment) -> Bool {
    return NSDictionary(dictionary: lhs.dictionaryRepresentation()).isEqual(to: rhs.dictionaryRepresentation())
}
