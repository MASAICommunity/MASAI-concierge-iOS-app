//
//  Timeline.swift
//  masai
//
//  Created by Bartomiej Burzec on 02.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation

struct Timeline: ReservationListData {
    let date: Date?
    
    init(_ date: Date?) {
        self.date = date
    }
    
    func reservationDataType() -> ReservationListDataType {
      return .timeline
    }
    
}
