//
//  SocketManager.swift
//  masai
//
//  Created by Bartomiej Burzec on 25.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import Starscream
import SwiftyJSON

class SocketManager {
    
    // MARK: Types
    
    typealias SocketManagerConnectionCompletion = (WebSocket? , Bool) -> Void
    typealias SocketManagerMessageCompletion = (SocketResponseMessage) -> Void
    
    
    // MARK: Properties
    
    var host: Host
    
    var sockets = [String: WebSocket]()
    
    var responseQueue = [String: [String : SocketManagerMessageCompletion]]()
    //TODO: delegates for concrete connection
    var connectionDelegates = [String: SocketManagerConnectionDelegate]()
    //FIXME: conversation delegates not handle rid per host
    var subscribedConversationDelegates = [String: [SubscribedConversationDelegate]]()
    var shouldReconnect = true
    var reconectigAttemps = 0
    
    internal var connectionCompletions = [String: SocketManagerConnectionCompletion]()
    
    private var connectionChecker: SocketConnectionCheck?
    
    private var notificationToken: Any?
    
    
    // MARK: Lifecycle
    
    init(host: Host) {
        self.host = host
        
        notificationToken = PushNotifications.deviceTokenReceived.observe { (note: Notification) in
            guard let userInfo = note.userInfo,
                let deviceToken = userInfo["token"] as? String else {
                    return
            }
            
            guard let creds = self.host.credentials,
                let userId = creds.liveChatUserId else {
                    return
            }
            
            RocketChatPushNotifications.register(deviceToken: deviceToken, userId: userId, socketManager: self, completion: { (didSucceed: Bool) in
                // do nothing here
            })
        }
    }
    
    deinit {
        if let token = notificationToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    
    // MARK: Public
    
    func clear() {
        subscribedConversationDelegates = [:]
    }
    
    func isConnected(with host: Host) -> Bool {
        guard let url = URL(string: host.socketUrl) else {
            return false
        }
        
        let socket = self.socket(with: url)
        return socket.isConnected
    }
    
    func connect(_ completion: @escaping SocketManagerConnectionCompletion) {
        let socketUrl = URL(string: host.socketUrl)!
        connect(url: socketUrl, completion: completion)
    }
    
    func disconnect(_ complection: SocketManagerConnectionCompletion? = nil) {
        let socketUrl = URL(string: host.socketUrl)!
        disconnect(socketUrl, completion: complection)
    }
    
    func send(_ object: [String: Any], completionResponse: SocketManagerMessageCompletion? = nil) {
        let socketUrl = URL(string: host.socketUrl)!
        send(object, url: socketUrl, completionResponse: completionResponse)
    }
    
    func subscribe(channel: Channel, delegate: SubscribedConversationDelegate) {
        guard let rid = channel.roomId else {
            return
        }
        
        HostConnectionManager.shared.activeHost(forRoomId: rid) { [unowned self] (host: Host?) in
            guard let host = host else {
                return
            }
            
            if self.subscribedConversationDelegates[rid] != nil {
                self.subscribedConversationDelegates[rid]!.append(delegate)
            } else {
                self.subscribedConversationDelegates[rid] = [delegate]
            }
            
            let url = URL(string: host.socketUrl)!
            self.renewSubscription(url: url, rid: rid)
        }
    }
    
    func unsubscribe(channel: Channel, delegate: SubscribedConversationDelegate) {
        guard let rid = channel.roomId,
            let delegates = subscribedConversationDelegates[rid] else {
            return
        }
        
        for (index, delegateToRemove) in delegates.enumerated().reversed() where delegateToRemove.delegateIdentifier() == delegate.delegateIdentifier() {
            subscribedConversationDelegates[rid]?.remove(at: index)
        }
    }
    
    static func connectionObject() -> [String: Any] {
        return ["msg" : "connect", "version" : "1", "support" : ["1", "pre2", "pre1"]] as [String: Any]
    }
    
    func addConnectionDelegate(_ delegate: SocketManagerConnectionDelegate) -> Bool {
        if connectionDelegates[delegate.delegateIdentifier()] != nil {
            return false
        }
        
        connectionDelegates[delegate.delegateIdentifier()] = delegate
        return true
    }
    
    func removeConnectionDelegate(_ delegate: SocketManagerConnectionDelegate) {
        if (connectionDelegates[delegate.delegateIdentifier()] != nil) {
            connectionDelegates.removeValue(forKey: delegate.delegateIdentifier())
        }
    }
    
    
    
    // MARK: Private
    
    private func socket(with url:URL) -> WebSocket {
        if let socket = self.sockets[url.absoluteString] {
            return socket
        }
        
        let newSocket = WebSocket(url: url)
        newSocket.timeout = 30
        newSocket.delegate = self
        newSocket.pongDelegate = self
        
        self.sockets[url.absoluteString] = newSocket
        return newSocket
    }
    
    private func connect(url: URL, completion: @escaping SocketManagerConnectionCompletion) {
//        connectionCompletions[url.absoluteString] = completion
        let socket = self.socket(with: url)
        
        if !socket.isConnected {
            socket.connect()
        }
        
        connectionChecker = SocketConnectionCheck()
        connectionChecker!.check(socket: socket, completion: completion)
    }
    
    private func disconnect(_ url: URL, completion: SocketManagerConnectionCompletion?) {
        let key = url.absoluteString
        if let socket = sockets[key] {
            connectionCompletions[key] = completion
            socket.disconnect()
        } else {
            completion?(nil, false)
        }
    }
    
    internal func send(_ object: [String: Any], url: URL,completionResponse: SocketManagerMessageCompletion? = nil) {
        let socket = self.socket(with: url)
        if socket.isConnected {
            var jsonObject = JSON(object)
            let uniqueMessageIdentifier  = String.random(length: 50)
            
            jsonObject["id"] = JSON(uniqueMessageIdentifier)
            
            if let jsonString = jsonObject.rawString() {
                socket.write(string: jsonString, completion: nil)
            } else {
                print("[SocketManager]: Send - Invalid JSON")
            }
            
            if let completion = completionResponse {
                if responseQueue[url.absoluteString] != nil {
                    responseQueue[url.absoluteString]![uniqueMessageIdentifier] = completion
                } else {
                    responseQueue[url.absoluteString] = [uniqueMessageIdentifier: completion]
                }
            }
        } else {
            //TODO: what should we do here?
            print("Socket not connected!")
        }
    }
    
    fileprivate func renewSubscription(url: URL, rid: String) {
        
        let requestObject = [
            Constants.Network.Json.message : Constants.Network.Json.subscribe,
            Constants.Network.Json.name : Constants.Network.Json.roomStream,
            Constants.Network.Json.params: [rid, false]
            ] as [String : Any]
        
        send(requestObject, url: url)
    }
    
}


extension SocketManager: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocket) {
        let socketUrl = socket.key()
        print("Socket connected with host: \(socketUrl)")
        
        send(SocketManager.connectionObject(), url: socket.currentURL)
        
        if let completionForSocket = self.connectionCompletions[socket.currentURL.absoluteString] {
            completionForSocket(socket, socket.isConnected)
        }
        
        for (_, delegate) in self.connectionDelegates {
            delegate.onSocketConnected()
        }
        
        if socket.reconnecting {
            socket.reconnecting = false
            
            HostConnectionManager.shared.credentials(forSocketUrl: socketUrl, completion: { [unowned self] (host: Host?, _: LiveChatCredentials?) in
                guard let host = host else {
                    return
                }
                
                for rid in self.subscribedConversationDelegates {
                    self.renewSubscription(url: URL(string: socket.key())!, rid: rid.key)
                }
                
                self.resentUnsentMessages(host.channels)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.onReconnectToHost()
            })
        }
        
    }
    
    func resentUnsentMessages(_ channels: [Channel]) {
        let unsentMessages = channels.flatMap({ $0.unsentMessages() })
        for msg in unsentMessages {
            let foundChannels = channels.filter { $0.roomId == msg.rid }
            guard foundChannels.count > 0 else {
                continue
            }
            let channelForMessage = foundChannels[0]
            
            switch msg.dataType() {
            case .image:
                UploadManager.sharedInstance.reupload(channel: channelForMessage, message: msg)
            case .location:
                resendLocalization(roomId: channelForMessage.roomId!, message: msg)
            default:
                resendTextMessage(in: channelForMessage, message: msg)
            }
        }
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("[WebSocket]: connection (\(socket.key())) did disconnect with error (\(String(describing: error)))")
        
        let key = socket.key()
        if let _ = connectionCompletions[key] {
            //            connectionCompletion(socket, socket.isConnected)
            //FIXME: not good solution
            connectionCompletions.removeValue(forKey: key)
        }
        
        if responseQueue[key] != nil {
            responseQueue.removeValue(forKey: key)
        }
       
        if shouldReconnect {
            socket.reconnecting = true
            socket.connect()
        }
        
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("[WebSocket] did receive data (\(data))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let jsonMessage = JSON.init(parseJSON: text)
        
        if let jsonString =  jsonMessage.rawString() {
            print("[WebSocket] Recieved message - \(jsonString)")
            handleResponse(jsonMessage, socket: socket)
        } else {
            print("[WebSocket] Recived Message - Invalid Json \(text)")
        }
    }
}

extension SocketManager: WebSocketPongDelegate {
    func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        print("[WebSocketManager] PONG")
    }
    
}
