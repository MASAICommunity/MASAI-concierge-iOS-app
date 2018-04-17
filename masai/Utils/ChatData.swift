//
//  ChatData.swift
//  masai
//
//  Created by Bartomiej Burzec on 14.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation

enum ChatDataType {
    case message
    case image
    case timeDivisor
    case googlePlaces
    case location
    case link
    case attachment
    case permission
    case permissionAnswer
    case undefined
    case closeChannelMessage
}

protocol ChatData {
    func dataType() -> ChatDataType
}
