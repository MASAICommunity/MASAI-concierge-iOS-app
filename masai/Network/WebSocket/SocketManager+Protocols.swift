//
//  SocketManager+Protocols.swift
//  masai
//
//  Created by Bartomiej Burzec on 26.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Starscream

protocol SocketManagerConnectionDelegate {
    func onSocketConnected()
    func onSocketDisconnected(_ socket: WebSocket?)
    func delegateIdentifier() -> String
}

protocol SubscribedConversationDelegate {
    func onUpdate(message: ChatMessage, response: SocketResponseMessage)
    func delegateIdentifier() -> String
}
