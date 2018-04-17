//
//  SocketResponseError.swift
//  masai
//
//  Created by Bartomiej Burzec on 27.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//
import SwiftyJSON
import Foundation

//TODO: ERROR KOD TO RAZ STRING RAZ INT - ODPOWIEDNIE PARSOWANIE

struct SocketResponseError {
    var errorCode: String?
    var reason: String?
    var message: String?
    var type: String?
    
    init(_ json: JSON) {
        self.errorCode = json["error"].string
        self.reason = json["reason"].string
        self.message = json["message"].string
        self.type = json["errorType"].string
    }
}
