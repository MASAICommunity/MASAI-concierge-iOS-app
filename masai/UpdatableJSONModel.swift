//
//  UpdatableModel.swift
//  masai
//
//  Created by Bartomiej Burzec on 02.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol UpdatableJSONModel {
    mutating func update(_ json: JSON)
}
