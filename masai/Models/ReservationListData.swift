//
//  ReservationListData.swift
//  masai
//
//  Created by Bartomiej Burzec on 02.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation

enum ReservationListDataType {
    case timeline
    case reservation
}


protocol ReservationListData {
    func reservationDataType() -> ReservationListDataType
}
