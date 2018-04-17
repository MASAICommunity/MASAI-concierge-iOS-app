//
//  PublicTransport.swift
//  masai
//
//  Created by Bartomiej Burzec on 01.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PublicTransport: ReservationBaseModel, UpdatableJSONModel{
    
    var bookingDetailsUrl: String?
    var trainNumber: String?
    var seat: String?
    var cabin: String?
    var classType: String?
    var duration: Int?
    
    var traveller = Traveller()
    var totalPrice = Price()
    var departure = Station()
    var arrival = Station()
    
    
    mutating func update(_ json: JSON) {
        self.bookingDetailsUrl = json[Constants.Reservations.Json.bookingDetails][Constants.Reservations.Json.url].string
        self.trainNumber = json[Constants.Reservations.Json.trainNumber].string
        self.seat = json[Constants.Reservations.Json.seat].string
        self.cabin = json[Constants.Reservations.Json.cabin].string
        self.classType = json[Constants.Reservations.Json.classType].string
        self.duration = json[Constants.Reservations.Json.duration].int
        
        self.traveller.update(json[Constants.Reservations.Json.traveller])
        self.totalPrice.update(json[Constants.Reservations.Json.totalPrice])
        self.departure.update(json[Constants.Reservations.Json.departure])
        self.arrival.update(json[Constants.Reservations.Json.arrival])
    }
    
    func reservationType() -> ReservationType {
        return .publicTransport
    }
    
    func reservationDate() -> Date? {
        return self.departure.utcDate
    }
    
    func reservationDataType() -> ReservationListDataType {
        return .reservation
    }
}
