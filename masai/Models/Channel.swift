//
//  Channel.swift
//  masai
//
//  Created by Bartomiej Burzec on 06.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation


struct Channel {
    
    // MARK: Properties
    
    /// The name of the room (currently the same name as the host).
    var name: String
    
    /// The id of the room on the rocket chat. If this is not set, we are not yet registered on rocket chat.
    var roomId: String?
    
    /// True if the channel is already closed, false if not
    var isClosed: Bool = false
    
    
    // MARK: Lifecycle
    
    init(name: String, roomId: String? = nil) {
        self.name = name
        self.roomId = roomId
    }
    
}


// MARK: Equatable
extension Channel: Equatable {
    
    static func ==(lhs: Channel, rhs: Channel) -> Bool {
        return lhs.name == rhs.name && lhs.roomId == rhs.roomId
    }
}


// MARK: Hashable
extension Channel: Hashable {
    
    var hashValue: Int {
        let nameHash = name.hashValue
        let roomHash = roomId?.hashValue ?? 0
        return nameHash ^ roomHash
    }
}

