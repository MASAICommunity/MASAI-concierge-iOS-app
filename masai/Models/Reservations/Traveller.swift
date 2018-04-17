//
//  Traveller.swift
//  masai
//
//  Created by Bartomiej Burzec on 01.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Traveller: UpdatableJSONModel {
    
    var firstName: String?
    var lastName: String?
    var classType: String?
    var eTicket: String?
    var price = Price()
    
    mutating func update(_ json: JSON) {
        self.firstName = json[Constants.Reservations.Json.firstName].string
        self.lastName = json[Constants.Reservations.Json.lastName].string
        self.classType = json[Constants.Reservations.Json.classType].string
        self.eTicket = json[Constants.Reservations.Json.eTicketNumber].string
        self.price.update(json[Constants.Reservations.Json.price])
    }
    
}
