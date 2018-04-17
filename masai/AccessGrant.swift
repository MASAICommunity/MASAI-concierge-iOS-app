//
//  AccessGrant.swift
//  masai
//
//  Created by Florian Rath on 26.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON


struct AccessGrant {
    
    // MARK: Properties
    
    let userId: String
    let grantedToUserId: String
    let scopes: [String]
    
    
    // MARK: Public
    
    static func from(json: JSON) -> [AccessGrant] {
        var grants: [AccessGrant] = []
        
        let items = json["Items"].array
        for jsonStruct in (items ?? []) {
            let userId = jsonStruct["UserId"]["S"].stringValue
            let grantedTo = jsonStruct["GrantedUserId"]["S"].stringValue
            
            var scopes: [String] = []
            let scopeDicts = jsonStruct["Scope"]["L"].array
            for scope in (scopeDicts ?? []) {
                scopes.append(scope["S"].stringValue)
            }
            
            let grant = AccessGrant(userId: userId, grantedToUserId: grantedTo, scopes: scopes)
            grants.append(grant)
        }
        
        return grants
    }
    
}
