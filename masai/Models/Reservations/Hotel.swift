//
//  Hotel.swift
//  masai
//
//  Created by Bartomiej Burzec on 01.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Hotel: ReservationBaseModel, UpdatableJSONModel {
    
    var notes: String?
    var bookingName: String?
    var bookingConfirmationNumber: String?
    var providerName: String?
    var providerPhone: String?
    var proviederConfirmationNumber: String?
    var hotelName: String?
    var checkIn: Date?
    var checkOut: Date?
    var room: String?
    var phone: String?
    var fax: String?

    var guest = Guest()
    var totalPrice = Price()
    var address = Address()
    
    
    mutating func update(_ json: JSON) {
        self.notes = json[Constants.Reservations.Json.notes].string
        self.bookingName = json[Constants.Reservations.Json.bookingDetails][Constants.Reservations.Json.name].string
        self.bookingConfirmationNumber = json[Constants.Reservations.Json.bookingDetails][Constants.Reservations.Json.confirmationNumber].string
        self.providerName = json[Constants.Reservations.Json.providerDetails][Constants.Reservations.Json.name].string
        self.providerPhone = json[Constants.Reservations.Json.providerDetails][Constants.Reservations.Json.phone].string
        self.proviederConfirmationNumber = json[Constants.Reservations.Json.providerDetails][Constants.Reservations.Json.confirmationNumber].string
        self.hotelName = json[Constants.Reservations.Json.hotelName].string
        self.checkIn = Date.dateDayFormat(json[Constants.Reservations.Json.checkIn].string)
        self.checkOut = Date.dateDayFormat(json[Constants.Reservations.Json.checkOut].string)
        self.room = json[Constants.Reservations.Json.room].string
        self.phone = json[Constants.Reservations.Json.phone].string
        self.fax = json[Constants.Reservations.Json.fax].string
        
        self.guest.update(json[Constants.Reservations.Json.guest])
        self.totalPrice.update(json[Constants.Reservations.Json.totalPrice])
        self.address.update(json[Constants.Reservations.Json.address])
    }
    
    func reservationType() -> ReservationType {
        return .hotel
    }
    
    func reservationDate() -> Date? {
        return self.checkIn
    }

    func reservationDataType() -> ReservationListDataType {
        return .reservation
    }
    
}
