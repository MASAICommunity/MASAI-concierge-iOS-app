//
//  Channel+JSON.swift
//  masai
//
//  Created by Florian Rath on 06.11.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON


extension Channel {
    
    // MARK: Lifecycle
    
    init(_ json: JSON) {
        self.init(name: "test")
        update(with: json)
    }
    
    
    // MARK: Public
    
    mutating func update(with json: JSON) {
        roomId = json["rid"].stringValue
    }
    
    func textMessageForTravelFolderAccess(_ permision: Bool) -> String? {
        if let rid = roomId,
            let user = CacheManager.retrieveLoggedUser(), let userId = user.identifier {
            var status = Constants.Network.PermissionsTypes.denied
            if permision {
                status = Constants.Network.PermissionsTypes.granted
            }
            
            let jsonMessage = [Constants.Network.Json.status: status,
                               Constants.Network.Json.granted: userId,
                               Constants.Network.Json.rid: rid]
            
            return JSON(jsonMessage).rawString()
        }
        return nil
    }
    
}
