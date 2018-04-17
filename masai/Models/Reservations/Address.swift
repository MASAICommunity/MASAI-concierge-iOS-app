//
//  ReservationAddress.swift
//  masai
//
//  Created by Bartomiej Burzec on 01.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Address: UpdatableJSONModel {
    var latitude: Double?
    var longitude: Double?
    var street: String?
    var city: String?
    var stateCode: String?
    var countryCode: String?
    var coutryName: String?
    var postalCode: Int?

    mutating func update(_ json: JSON) {
        self.longitude = json[Constants.Reservations.Json.longitude].double
        self.latitude = json[Constants.Reservations.Json.lattitude].double
        self.longitude = json[Constants.Reservations.Json.longitude].double
        self.street = json[Constants.Reservations.Json.street].string
        self.city = json[Constants.Reservations.Json.city].string
        self.stateCode = json[Constants.Reservations.Json.stateCode].string
        self.countryCode = json[Constants.Reservations.Json.countryCode].string
        self.coutryName = json[Constants.Reservations.Json.countryName].string
        self.postalCode = json[Constants.Reservations.Json.postalCode].int
    }
}
