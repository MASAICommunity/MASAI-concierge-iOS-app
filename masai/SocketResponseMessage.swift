//
//  SocketResponseMessage.swift
//  masai
//
//  Created by Bartomiej Burzec on 25.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import SwiftyJSON

public struct SocketResponseMessage {
    var responseData: JSON
    var messageType: SocketResponseMessageType?
    var identifier: String?
    var error: SocketResponseError?
    var event: String?
    
    init(_ responseData: JSON) {
      self.responseData = responseData
      self.identifier = self.responseData[Constants.Network.Json.id].string
        
        if let eventName = self.responseData[Constants.Network.Json.fields][Constants.Network.Json.eventName].string {
            self.event = eventName
        }
        
        if let msg = self.responseData[Constants.Network.Json.message].string {
            self.messageType = SocketResponseMessageType(rawValue: msg) ?? SocketResponseMessageType.Unknown
            
            if self.messageType == .Changed,
                let actualMessage = self.responseData[Constants.Network.Json.fields][Constants.Network.Json.args][0][Constants.Network.Json.message].string,
                actualMessage == SocketResponseMessageType.CloseChannel.rawValue {
                self.messageType = SocketResponseMessageType.CloseChannel
            }
        }
        
        if responseData[Constants.Network.Json.error].exists() {
            self.error = SocketResponseError(responseData[Constants.Network.Json.error])
        }
    }
    
    func errorOccured() -> Bool {
        return self.error != nil
    }
    
}
