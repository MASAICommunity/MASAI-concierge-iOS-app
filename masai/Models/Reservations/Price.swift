//
//  Price.swift
//  masai
//
//  Created by Bartomiej Burzec on 01.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Price: UpdatableJSONModel  {
    
    var totalCost: Double?
    var currencyCode: String?
    
    mutating func update(_ json: JSON) {
        self.totalCost = json[Constants.Reservations.Json.totalCost].double
        self.currencyCode = json[Constants.Reservations.Json.currencyCode].string
    }
    
    func reservationType() -> ReservationType {
        return .none
    }
}
