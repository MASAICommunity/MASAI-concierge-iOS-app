//
//  TrainSegment.swift
//
//  Created by Florian Rath on 27.08.17
//  Copyright (c) Codepool GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON


public struct TrainSegment: Segment {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let destinationName = "destination_name"
    static let originName = "origin_name"
    static let travelers = "travelers"
    static let destinationCityName = "destination_city_name"
    static let trainNumber = "train_number"
    static let source = "source"
    static let originAdminCode = "origin_admin_code"
    static let destinationAdminCode = "destination_admin_code"
    static let originLat = "origin_lat"
    static let type = "type"
    static let numberOfPax = "number_of_pax"
    static let lastName = "last_name"
    static let currency = "currency"
    static let tickets = "tickets"
    static let destinationLon = "destination_lon"
    static let originLon = "origin_lon"
    static let destinationLat = "destination_lat"
    static let seats = "seats"
    static let departureDatetime = "departure_datetime"
    static let originCountry = "origin_country"
    static let originCityName = "origin_city_name"
    static let railLine = "rail_line"
    static let arrivalTimeZoneId = "arrival_time_zone_id"
    static let arrivalDatetime = "arrival_datetime"
    static let price = "price"
    static let ticketNumber = "ticket_number"
    static let status = "status"
    static let origin = "origin"
    static let destination = "destination"
    static let created = "created"
    static let destinationCountry = "destination_country"
    static let seatAssignment = "seat_assignment"
    static let firstName = "first_name"
    static let departureTimeZoneId = "departure_time_zone_id"
    static let confirmationNo = "confirmation_no"
    static let priceDetails = "price_details"
  }

  // MARK: Properties
    public var destinationName: String?
    public var originName: String?
  public var travelers: [Travelers]?
  public var destinationCityName: String?
  public var trainNumber: String?
  public var source: String?
  public var originAdminCode: String?
  public var destinationAdminCode: String?
  public var originLat: String?
  public var type: String?
  public var numberOfPax: String?
  public var lastName: String?
  public var currency: String?
  public var tickets: [String]?
  public var destinationLon: String?
  public var originLon: String?
  public var destinationLat: String?
  public var seats: [String]?
  public var departureDatetime: String?
  public var originCountry: String?
  public var originCityName: String?
  public var railLine: String?
  public var arrivalTimeZoneId: String?
  public var arrivalDatetime: String?
  public var price: String?
  public var ticketNumber: String?
  public var status: String?
  public var origin: String?
  public var destination: String?
  public var created: String?
  public var destinationCountry: String?
  public var seatAssignment: String?
  public var firstName: String?
  public var departureTimeZoneId: String?
  public var confirmationNo: String?
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
    destinationName = json[SerializationKeys.destinationName].string
    originName = json[SerializationKeys.originName].string
    destinationCityName = json[SerializationKeys.destinationCityName].string
    trainNumber = json[SerializationKeys.trainNumber].string
    source = json[SerializationKeys.source].string
    originAdminCode = json[SerializationKeys.originAdminCode].string
    destinationAdminCode = json[SerializationKeys.destinationAdminCode].string
    originLat = json[SerializationKeys.originLat].string
    type = json[SerializationKeys.type].string
    numberOfPax = json[SerializationKeys.numberOfPax].string
    lastName = json[SerializationKeys.lastName].string
    currency = json[SerializationKeys.currency].string
    if let items = json[SerializationKeys.tickets].array { tickets = items.map { $0.stringValue } }
    destinationLon = json[SerializationKeys.destinationLon].string
    originLon = json[SerializationKeys.originLon].string
    destinationLat = json[SerializationKeys.destinationLat].string
    if let items = json[SerializationKeys.seats].array { seats = items.map { $0.stringValue } }
    departureDatetime = json[SerializationKeys.departureDatetime].string
    originCountry = json[SerializationKeys.originCountry].string
    originCityName = json[SerializationKeys.originCityName].string
    railLine = json[SerializationKeys.railLine].string
    arrivalTimeZoneId = json[SerializationKeys.arrivalTimeZoneId].string
    arrivalDatetime = json[SerializationKeys.arrivalDatetime].string
    price = json[SerializationKeys.price].string
    ticketNumber = json[SerializationKeys.ticketNumber].string
    status = json[SerializationKeys.status].string
    origin = json[SerializationKeys.origin].string
    destination = json[SerializationKeys.destination].string
    created = json[SerializationKeys.created].string
    destinationCountry = json[SerializationKeys.destinationCountry].string
    seatAssignment = json[SerializationKeys.seatAssignment].string
    firstName = json[SerializationKeys.firstName].string
    departureTimeZoneId = json[SerializationKeys.departureTimeZoneId].string
    confirmationNo = json[SerializationKeys.confirmationNo].string
    if let items = json[SerializationKeys.priceDetails].array { priceDetails = items.map { PriceDetails(json: $0) } }
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = destinationName { dictionary[SerializationKeys.destinationName] = value }
    if let value = originName { dictionary[SerializationKeys.originName] = value }
    if let value = travelers { dictionary[SerializationKeys.travelers] = value.map { $0.dictionaryRepresentation() } }
    if let value = destinationCityName { dictionary[SerializationKeys.destinationCityName] = value }
    if let value = trainNumber { dictionary[SerializationKeys.trainNumber] = value }
    if let value = source { dictionary[SerializationKeys.source] = value }
    if let value = originAdminCode { dictionary[SerializationKeys.originAdminCode] = value }
    if let value = destinationAdminCode { dictionary[SerializationKeys.destinationAdminCode] = value }
    if let value = originLat { dictionary[SerializationKeys.originLat] = value }
    if let value = type { dictionary[SerializationKeys.type] = value }
    if let value = numberOfPax { dictionary[SerializationKeys.numberOfPax] = value }
    if let value = lastName { dictionary[SerializationKeys.lastName] = value }
    if let value = currency { dictionary[SerializationKeys.currency] = value }
    if let value = tickets { dictionary[SerializationKeys.tickets] = value }
    if let value = destinationLon { dictionary[SerializationKeys.destinationLon] = value }
    if let value = originLon { dictionary[SerializationKeys.originLon] = value }
    if let value = destinationLat { dictionary[SerializationKeys.destinationLat] = value }
    if let value = seats { dictionary[SerializationKeys.seats] = value }
    if let value = departureDatetime { dictionary[SerializationKeys.departureDatetime] = value }
    if let value = originCountry { dictionary[SerializationKeys.originCountry] = value }
    if let value = originCityName { dictionary[SerializationKeys.originCityName] = value }
    if let value = railLine { dictionary[SerializationKeys.railLine] = value }
    if let value = arrivalTimeZoneId { dictionary[SerializationKeys.arrivalTimeZoneId] = value }
    if let value = arrivalDatetime { dictionary[SerializationKeys.arrivalDatetime] = value }
    if let value = price { dictionary[SerializationKeys.price] = value }
    if let value = ticketNumber { dictionary[SerializationKeys.ticketNumber] = value }
    if let value = status { dictionary[SerializationKeys.status] = value }
    if let value = origin { dictionary[SerializationKeys.origin] = value }
    if let value = destination { dictionary[SerializationKeys.destination] = value }
    if let value = created { dictionary[SerializationKeys.created] = value }
    if let value = destinationCountry { dictionary[SerializationKeys.destinationCountry] = value }
    if let value = seatAssignment { dictionary[SerializationKeys.seatAssignment] = value }
    if let value = firstName { dictionary[SerializationKeys.firstName] = value }
    if let value = departureTimeZoneId { dictionary[SerializationKeys.departureTimeZoneId] = value }
    if let value = confirmationNo { dictionary[SerializationKeys.confirmationNo] = value }
    if let value = priceDetails { dictionary[SerializationKeys.priceDetails] = value.map { $0.dictionaryRepresentation() } }
    return dictionary
  }
    
    // MARK: Public
    
    public var userFacingStartDateString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: departureDatetime) else {
            return nil
        }
        
        return tuple.0
    }
    
    public var userFacingStartTimeString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: departureDatetime) else {
            return nil
        }
        
        return tuple.1
    }
    
    public var userFacingEndDateString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: arrivalDatetime) else {
            return nil
        }
        
        return tuple.0
    }
    
    public var userFacingEndTimeString: String? {
        guard let tuple = SegmentFactory.dateTimeFrom(backendDateString: arrivalDatetime) else {
            return nil
        }
        
        return tuple.1
    }

}


// MARK: Equatable
extension TrainSegment: Equatable {}

public func ==(lhs: TrainSegment, rhs: TrainSegment) -> Bool {
    return NSDictionary(dictionary: lhs.dictionaryRepresentation()).isEqual(to: rhs.dictionaryRepresentation())
}
