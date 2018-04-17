//
//  SocketResponseMessageType.swift
//  masai
//
//  Created by Bartomiej Burzec on 25.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

enum SocketResponseMessageType: String {
    case Connected = "connected"
    case Error = "error"
    case Ping = "ping"
    case Changed = "changed"
    case Added = "added"
    case Updated = "updated"
    case Removed = "removed"
    case CloseChannel = "promptTranscript"
    case Unknown
}
