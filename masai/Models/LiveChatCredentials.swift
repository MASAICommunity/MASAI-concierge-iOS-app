//
//  LiveChatCredentials.swift
//  masai
//
//  Created by Bartomiej Burzec on 11.04.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import Pantry

struct LiveChatCredentials: Storable {
    
    // MARK: Properties
    
    var liveChatUserLoginToken: String?
    var liveChatUserId: String?
    var liveChatUsername: String?
    
    
    // MARK: Lifecycle
    
    init() {}
    
    init(liveChatUserLoginToken: String?, liveChatUserId: String?, liveChatUsername: String?) {
        self.liveChatUserLoginToken = liveChatUserLoginToken
        self.liveChatUserId = liveChatUserId
        self.liveChatUsername = liveChatUsername
    }
    
    
    // MARK: Pantry
    
    init?(warehouse: Warehouseable) {
        self.liveChatUserLoginToken = warehouse.get("liveChatUserLoginToken")
        self.liveChatUserId = warehouse.get("liveChatUserId")
        self.liveChatUsername = warehouse.get("liveChatUsername")
    }
    
}
