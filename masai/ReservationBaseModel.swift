//
//  ReservationBaseModel.swift
//  masai
//
//  Created by Bartomiej Burzec on 01.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ReservationType {
    case flight
    case hotel
    case publicTransport
    case none
}

protocol ReservationBaseModel: ReservationListData {
    func reservationType() -> ReservationType
    func reservationDate() -> Date?
    
}
