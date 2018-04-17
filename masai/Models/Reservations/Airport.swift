//
//  Airport.swift
//  masai
//
//  Created by Bartomiej Burzec on 01.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Airport: UpdatableJSONModel {
    
    var latitude: Double?
    var longitude: Double?
    var code: String?
    var name: String?
    var terminal: String?
    var gate: String?
    var localDate: Date?
    var utcDate: Date?
    
    mutating func update(_ json: JSON) {
        self.latitude = json[Constants.Reservations.Json.lattitude].double
        self.longitude = json[Constants.Reservations.Json.longitude].double
        self.code = json[Constants.Reservations.Json.airportCode].string
        self.name = json[Constants.Reservations.Json.name].string
        self.terminal = json[Constants.Reservations.Json.terminal].string
        self.gate = json[Constants.Reservations.Json.gate].string
        self.localDate = Date.dateWithFullFormat(json[Constants.Reservations.Json.localDate].string)
        self.utcDate = Date.dateWithFullFormat(json[Constants.Reservations.Json.utcDate].string)
    }

}
