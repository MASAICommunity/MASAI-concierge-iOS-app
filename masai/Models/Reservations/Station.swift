//
//  Station.swift
//  masai
//
//  Created by Bartomiej Burzec on 01.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Station: UpdatableJSONModel {
    var name: String?
    var localDate: Date?
    var utcDate: Date?
    var platform: String?
    var stationCode: String?
    var address = Address()
    
    
    mutating func update(_ json: JSON) {
        self.name = json[Constants.Reservations.Json.stationName].string
        self.localDate = Date.dateWithFullFormat(json[Constants.Reservations.Json.localDate].string)
        self.utcDate = Date.dateWithFullFormat(json[Constants.Reservations.Json.utcDate].string)
        self.platform = json[Constants.Reservations.Json.platform].string
        self.stationCode = json[Constants.Reservations.Json.stationCode].string
        
        self.address.update(json[Constants.Reservations.Json.address])
    }
    
}
