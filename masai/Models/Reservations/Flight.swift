//
//  Flight.swift
//  masai
//
//  Created by Bartomiej Burzec on 01.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Flight : ReservationBaseModel, UpdatableJSONModel {

    var notes: String?
    var recordLocator: String?
    var bookingName: String?
    var bookingPhone: String?
    var bookingConfirmationNumber: String?
    var providerName: String?
    var providerConfirmationNumber: String?
    var detailNumber: Int?
    var arlineCode: String?
    var duration: Int?
    var distanceMiles: Int?
    var classType: String?

    var totalCost = Price()
    var departue = Airport()
    var arrival = Airport()
    var traveller = Traveller()
    
    
    mutating func update(_ json: JSON) {
        self.notes = json[Constants.Reservations.Json.notes].string
        self.recordLocator = json[Constants.Reservations.Json.recordLocator].string
        self.bookingName = json[Constants.Reservations.Json.bookingDetails][Constants.Reservations.Json.name].string
        self.bookingPhone = json[Constants.Reservations.Json.bookingDetails][Constants.Reservations.Json.phone].string
        self.bookingConfirmationNumber = json[Constants.Reservations.Json.bookingDetails][Constants.Reservations.Json.confirmationNumber].string
        self.providerName = json[Constants.Reservations.Json.providerDetails][Constants.Reservations.Json.name].string
        self.providerConfirmationNumber = json[Constants.Reservations.Json.providerDetails][Constants.Reservations.Json.confirmationNumber].string
        self.detailNumber = json[Constants.Reservations.Json.details][Constants.Reservations.Json.number].int
        self.arlineCode = json[Constants.Reservations.Json.details][Constants.Reservations.Json.number].string
        self.duration = json[Constants.Reservations.Json.duration].int
        self.distanceMiles = json[Constants.Reservations.Json.distanceInMiles].int
        self.classType = json[Constants.Reservations.Json.classType].string
        
        self.totalCost.update(json[Constants.Reservations.Json.totalPrice])
        self.departue.update(json[Constants.Reservations.Json.departure])
        self.arrival.update(json[Constants.Reservations.Json.arrival])
        self.traveller.update(json[Constants.Reservations.Json.traveller])
    }
    
    func reservationType() -> ReservationType {
        return .flight
    }
    
    func reservationDate() -> Date? {
        return departue.utcDate
    }
    
    func reservationDataType() -> ReservationListDataType {
        return .reservation
    }

}



