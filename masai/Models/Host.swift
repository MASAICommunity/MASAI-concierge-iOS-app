//
//  Host.swift
//  masai
//
//  Created by Bartomiej Burzec on 31.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//
import Foundation

struct Host {
    
    // MARK: Properties
    
    /// The url of the host
    var url: String
    
    /// The url of the websocket endpoint
    var socketUrl: String
    
    /// The name of the host
    var name: String
    
    /// The live chat token of the host
    var liveChatToken: String
    
    /// Subscribed channels (= rooms) for the host
    var channels: [Channel] = []
    
    /// The live chat credentials for the host
    var credentials: LiveChatCredentials? {
        didSet {
            print("got new credentials: \(String(describing: credentials)) for host \(self.name)")
        }
    }
    
    /// Tells if the host is active (meaning if he is served by the backend) or only for history purposes
    var isActive = true
    
    
    // MARK: Lifecycle

    init(url: String, socketUrl: String, name: String, liveChatToken: String, credentials: LiveChatCredentials?) {
        self.url = url
        self.socketUrl = socketUrl
        self.name = name
        self.liveChatToken = liveChatToken
        self.credentials = credentials
    }
    
    
    // MARK: Public
    
    mutating func addOrReplace(channel: Channel) {
        if let index = channels.index(of: channel) {
            channels.remove(at: index)
            channels.insert(channel, at: index)
        } else {
            channels.append(channel)
        }
    }
    
    mutating func remove(channel: Channel) {
        guard let index = channels.index(of: channel) else {
            return
        }
        channels.remove(at: index)
    }
    
    mutating func setRoomIdForUnregisteredChannel(_ roomId: String) {
        var unregisteredChannels = channels.filter { $0.roomId == nil }
        assert(unregisteredChannels.count == 1, "There should be exactly one unregistered channel")
        
        var channel = unregisteredChannels[0]
        let index = channels.index(of: channel)!
        
        var updatedChannels = channels
        updatedChannels.remove(at: index)
        channel.roomId = roomId
        updatedChannels.append(channel)
        channels = updatedChannels
    }
    
    mutating func cleanupUnregisteredChannels() {
        let cleanedChannels = channels.filter { $0.roomId != nil }
        channels = cleanedChannels
    }
    
    
    // MARK: Private
    
    func restEndpoint(_ methodName: String) -> String {
        guard let method = methodName.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            return ""
        }
        
        var sanitizedMethod = method
        if sanitizedMethod.hasPrefix("/") && url.hasSuffix("/") {
            sanitizedMethod = sanitizedMethod.substring(from: sanitizedMethod.index(sanitizedMethod.startIndex, offsetBy: 1))
        }
        
        return url + sanitizedMethod
    }
    
}


// MARK: Equatable
extension Host: Equatable {
    
    static func ==(lhs: Host, rhs: Host) -> Bool {
        return lhs.url == rhs.url && lhs.socketUrl == rhs.socketUrl && lhs.name == rhs.name && lhs.liveChatToken == rhs.liveChatToken
    }
}


// MARK: Hashable
extension Host: Hashable {
    
    var hashValue: Int {
        let urlHash = url.hashValue
        let socketHash = socketUrl.hashValue
        let nameHash = name.hashValue
        let tokenHash = liveChatToken.hashValue
        return urlHash ^ socketHash ^ nameHash ^ tokenHash
    }
}
