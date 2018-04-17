//
//  SocketManager+ResponseHandler.swift
//  masai
//
//  Created by Bartomiej Burzec on 25.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//
import SwiftyJSON
import Starscream
import RealmSwift

extension SocketManager {
    
    func handleResponse(_ response: JSON, socket: WebSocket) {
        let responseMessage = SocketResponseMessage(response)
        
        guard let message = responseMessage.messageType else {
            print("Response Message type is invalid \(responseMessage.responseData)")
            return
        }
        
        switch message {
        case .Ping:
            handlePongMessage(responseMessage, socket: socket)
            return
        case .Changed, .Added, .Removed:
            handleSubcription(responseMessage, socket: socket)
            return
        case .CloseChannel:
            handleCloseChannel(responseMessage, socket: socket)
            return
        default: break
        }
        
        guard let responseIdentifier = responseMessage.identifier else {
            return
        }
        
        if let completionsForSocket = self.responseQueue[socket.key()] {
            let completion = completionsForSocket[responseIdentifier]
            completion?(responseMessage)
        }
    }
    
    func handlePongMessage(_ message: SocketResponseMessage, socket: WebSocket) {
        send([Constants.Network.Json.message: Constants.Network.Json.pong], url: socket.currentURL)
    }
    
    func handleSubcription(_ message: SocketResponseMessage, socket: WebSocket) {
        guard let event = message.event,
            let delegates = self.subscribedConversationDelegates[event] else {
            return
        }
        
        let chatMessageJson = message.responseData[Constants.Network.Json.fields][Constants.Network.Json.args][0]
        
        guard let newMessage = MessageParser.parse(chatMessageJson) else {
            assert(false, "Could not create Chat Message from response message")
            return
        }
        
        for delegate in delegates {
            DispatchQueue.main.async {
                delegate.onUpdate(message: newMessage, response: message)
            }
        }
    }
    
    func handleCloseChannel(_ message: SocketResponseMessage, socket: WebSocket) {
        let chatMessageJson = message.responseData[Constants.Network.Json.fields][Constants.Network.Json.args][0]
        guard let chatMessage = MessageParser.parse(chatMessageJson) else {
            assert(false, "Could not create Chat Message from response message!")
            return
        }
        
        guard let rid = chatMessage.rid,
            let channel = HostConnectionManager.shared.cachedChannel(forRoomId: rid) else {
                assert(false, "Could not get channel for message")
                return
        }
        
        Constants.Notification.close(channel: channel, message: chatMessage).post()
    }
    
}
