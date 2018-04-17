//
//  HostConnectionManager.swift
//  masai
//
//  Created by Florian Rath on 26.10.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import PromiseKit
import Pantry


enum HostConnectionManagerError: Error {
    case couldNotConnect
    case noSocketManagerFound
}


class HostConnectionManager {
    
    // MARK: Singleton
    
    static let shared = HostConnectionManager()
    
    
    // MARK: Types
    
    typealias PrepareHostsClosure = () -> Void
    typealias GetHostsClosure = (_ hosts: [Host]) -> Void
    typealias ConnectionCompletionClosure = (_ didSuccessfullyConnectionAllHosts: Bool) -> Void
    typealias GetHostClosure = (_ host: Host?) -> Void
    typealias OpenChannelsClosure = (_ channels: [Channel]) -> Void
    typealias GetSocketManagerClosure = (_ socketManager: SocketManager?) -> Void
    typealias GetCredentialsClosure = (_ host: Host?, _ credentials: LiveChatCredentials?) -> Void
    private typealias HostRetrievalCompletionClosure = (_ hosts: [Host]) -> Void
    
    typealias UpdateCredentialsTuple = (didSucceed: Bool, updatedHost: Host)
    
    
    // MARK: Properties
    
    private var cachedHosts: [Host] = []
    private var cachedActiveHosts: [Host] {
        return openHosts(in: cachedHosts)
    }
    private var openConnections: [Host: SocketManager] = [:]
    var existingConnections: [Host: SocketManager] {
        return openConnections
    }
    
    
    // MARK: Public
    
    func prepareHostList(_ completion: @escaping PrepareHostsClosure) {
        // Load cached hosts
        var savedHosts = CacheManager.retrieveHosts()
        
        // Load backend host list
        HostConnectionManager.retrieveHostList { [unowned self] (backendHosts: [Host]) in
            
            // Mix saved hosts with information from the backend
            var newHosts: [Host] = []
            for backendHost in backendHosts {
                // Check if we have the backend host in our saved hosts
                guard var localHost = self.host(in: savedHosts, havingUrl: backendHost.url) else {
                    newHosts.append(backendHost)
                    continue
                }
                
                // Remove the host from our saved hosts
                let idx = savedHosts.index(of: localHost)!
                savedHosts.remove(at: idx)
                
                // We have found a saved host, so we'll update it with all backend values
                localHost.socketUrl = backendHost.socketUrl
                localHost.name = backendHost.name
                localHost.liveChatToken = backendHost.liveChatToken
                localHost.isActive = true
                newHosts.append(localHost)
            }
            
            // Archive all now nonexisting hosts
            for lostHost in savedHosts {
                var updatedHost = lostHost
                updatedHost.isActive = false
                
                let channels = updatedHost.channels
                for c in channels {
                    var updatedChannel = c
                    updatedChannel.isClosed = true
                    updatedHost.addOrReplace(channel: updatedChannel)
                }
                
                newHosts.append(updatedHost)
            }
            
            // Save all hosts locally and to our user defaults
            self.set(cachedHosts: newHosts, persist: true)
            
            completion()
        }
    }
    
    func getActiveHosts(_ completion: @escaping GetHostsClosure) {
        // If we already have a list of hosts from the backend, return it
        if cachedActiveHosts.count > 0 {
            DispatchQueue.main.async { [unowned self] in
                completion(self.cachedActiveHosts)
            }
            return
        }
        
        // If we don't have a list yet, we'll load it
        prepareHostList {
            DispatchQueue.main.async {
                completion(self.cachedActiveHosts)
            }
        }
    }
    
    func getAllHosts(_ completion: @escaping GetHostsClosure) {
        // If we already have a list of hosts from the backend, return it
        if cachedHosts.count > 0 {
            DispatchQueue.main.async { [unowned self] in
                completion(self.cachedHosts)
            }
            return
        }
        
        // If we don't have a list yet, we'll load it
        prepareHostList {
            DispatchQueue.main.async {
                completion(self.cachedHosts)
            }
        }
    }
    
    func forceReconnectToAllActiveHosts(_ completion: @escaping ConnectionCompletionClosure) {
        // Retrieve hosts
        getActiveHosts { [unowned self] (hosts) -> (Void) in
            // Disconnect all sockets
            for connection in self.openConnections.values {
                connection.disconnect()
            }
            
            // Clear our cached sockets
            self.openConnections = [:]
            
            // Clear credentials for host (to force reregistering on live chat)
            for host in hosts {
                self.update(credentials: nil, for: host)
            }
            
            // Connect to all active hosts
            self.connectToAllActiveHosts(completion)
        }
    }
    
    func connectToAllActiveHosts(_ completion: @escaping ConnectionCompletionClosure) {
        // Retrieve hosts
        getActiveHosts { (hosts) -> (Void) in
            
            let connectionPromises = hosts.map { self.connectTo(host: $0) }
            when(fulfilled: connectionPromises)
                .then { (_: [SocketManager]) in
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
                .catch { (error: Error) in
                    self.clearCachedHosts(persist: false)
                    DispatchQueue.main.async {
                        completion(false)
                    }
            }
        }
    }
    
    /// If there's already an existing connection to the host, it'll just get returned.
    /// Otherwise a connection attempt to the host is made.
    ///
    /// - Parameter host: The host to connect to.
    /// - Returns: A promise, fulfilling when the connection is existing or was successful and rejecting if the connection failed.
    func connectTo(host: Host) -> Promise<SocketManager> {
        return Promise { fulfill, reject in
            if !cachedHosts.contains(host) {
                addOrReplace(host: host)
            }
            
            if let socketManager = existingConnections[host] {
                socketManager.registerToLiveChat({ (response: SocketResponseMessage?, channel: Channel?, creds: LiveChatCredentials?) in
                    if let response = response,
                        response.errorOccured() == true {
                        reject(HostConnectionManagerError.couldNotConnect)
                        return
                    }
                    
                    guard let credentials = creds else {
                        reject(HostConnectionManagerError.couldNotConnect)
                        return
                    }
                    
                    self.update(credentials: credentials, for: host)
                    
                    self.updateChannels(for: host)
                        .then { (sm: SocketManager) -> Void in
                            Constants.Notification.socketConnected(host: host).post()
                            fulfill(sm)
                        }.catch(execute: { (error: Error) in
                            assert(false, "Could not update channels for the host")
                        })
                })
                return
            }
            
            let socketManager = SocketManager(host: host)
            socketManager.connect() { [unowned self] (socket, connected) in
                if connected {
                    self.openConnections[host] = socketManager
                    
                    socketManager.registerToLiveChat({ (_: SocketResponseMessage?, _: Channel?, creds: LiveChatCredentials?) in
                        
                        self.update(credentials: creds, for: host)
                        
                        self.updateChannels(for: host)
                            .then { (sm: SocketManager) -> Void in
                                Constants.Notification.socketConnected(host: host).post()
                                fulfill(sm)
                            }.catch(execute: { (error: Error) in
                                assert(false, "Could not update channels for the host")
                            })
                    })
                    return
                } else {
                    reject(HostConnectionManagerError.couldNotConnect)
                }
            }
        }
    }
    
    func updateChannels(for host: Host) -> Promise<SocketManager> {
        return Promise { fulfill, reject in
            guard let socketManager = socketManager(for: host) else {
                reject(HostConnectionManagerError.noSocketManagerFound)
                return
            }
            
            socketManager.getChannels({ [unowned self] (channels: [Channel]) in
                for c in channels {
                    self.addOrReplace(channel: c, to: host)
                }
                
                fulfill(socketManager)
                return
            })
        }
    }
    
    func clearCachedHosts(persist: Bool) {
        for host in cachedHosts {
            if let socketManager = openConnections[host] {
                socketManager.disconnect()
            }
        }
        set(cachedHosts: [], persist: persist)
        openConnections = [:]
    }
    
    func socketManager(for host: Host) -> SocketManager? {
        guard let socketManager = existingConnections[host] else {
            return nil
        }
        return socketManager
    }
    
    func socketManager(for channel: Channel) -> SocketManager? {
        guard let host = cachedActiveHost(for: channel) else {
            return nil
        }
        return socketManager(for: host)
    }
    
    func socketManager(for channel: Channel, completion: @escaping GetSocketManagerClosure) {
        guard let rid = channel.roomId else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        activeHost(forRoomId: rid) { [unowned self] (host: Host?) in
            guard let host = host else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let sm = self.socketManager(for: host)
            DispatchQueue.main.async {
                completion(sm)
            }
        }
    }
    
    func activeHost(forRoomId roomId: String, completion: @escaping GetHostClosure) {
        getActiveHosts { (hosts: [Host]) in
            let filteredHosts = hosts.filter({ (host) -> Bool in
                for channel in host.channels where channel.roomId == roomId {
                    return true
                }
                return false
            })
            
            if filteredHosts.count == 0 {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(filteredHosts[0])
            }
        }
    }
    
    func host(for channel: Channel, completion: @escaping GetHostClosure) {
        getAllHosts { (hosts: [Host]) in
            let filteredHosts = hosts.filter({ (host) -> Bool in
                for localChannel in host.channels where localChannel == channel {
                    return true
                }
                return false
            })
            
            if filteredHosts.count == 0 {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(filteredHosts[0])
            }
        }
    }
    
    func cachedActiveHost(for channel: Channel) -> Host? {
        let filteredHosts = cachedActiveHosts.filter({ (host) -> Bool in
            for c in host.channels where c == channel {
                return true
            }
            return false
        })
        
        if filteredHosts.count == 0 {
            return nil
        }
        return filteredHosts[0]
    }
    
    func cachedHost(for url: String) -> Host? {
        let filteredHosts = cachedHosts.filter { return $0.url == url }
        
        if filteredHosts.count == 0 {
            return nil
        }
        return filteredHosts[0]
    }
    
    func getOpenChannelsInActiveHosts(_ completion: @escaping OpenChannelsClosure) {
        getActiveHosts { (hosts: [Host]) in
            let channels = hosts.flatMap { $0.channels }
            let openChannels = channels.filter { $0.isClosed == false }
            
            DispatchQueue.main.async {
                completion(openChannels)
            }
        }
    }
    
    func getCachedOpenChannels() -> [Channel] {
        let channels = cachedActiveHosts.flatMap { $0.channels }
        let openChannels = channels.filter { $0.isClosed == false }
        return openChannels
    }
    
    func credentials(forSocketUrl hostUrl: String, completion: @escaping GetCredentialsClosure) {
        getAllHosts { (hosts: [Host]) in
            let foundHosts = hosts.filter { $0.socketUrl == hostUrl }
            guard foundHosts.count > 0 else {
                DispatchQueue.main.async {
                    completion(nil, nil)
                }
                return
            }
            let host = foundHosts[0]
            DispatchQueue.main.async {
                completion(host, host.credentials)
            }
        }
    }
    
    @discardableResult func update(credentials: LiveChatCredentials?, for host: Host) -> UpdateCredentialsTuple {
        var existingHost = getCachedCorrespondingHost(to: host)
        existingHost.credentials = credentials
        addOrReplace(host: existingHost)
        
        return (true, existingHost)
    }
    
    func addOrReplace(channel: Channel, to host: Host) {
        var existingHost = getCachedCorrespondingHost(to: host)
        existingHost.addOrReplace(channel: channel)
        addOrReplace(host: existingHost)
    }
    
    /// Removes a channel from its corresponding host. May be called whenever a channel is archived (and thus is no active channel of the host anymore).
    ///
    /// - Parameter channel: The channel which should be removed from its corresponding host.
    func remove(channel: Channel) {
        let hostsContainingChannel = cachedHosts.filter { $0.channels.contains(channel) }
        guard hostsContainingChannel.count == 1 else {
            assert(false, "No host found containing the channel which should be removed!")
            return
        }
        var foundHost = hostsContainingChannel[0]
        foundHost.remove(channel: channel)
        addOrReplace(host: foundHost)
    }
    
    func set(roomId: String, forUnregisteredChannelIn host: Host) {
        var localHost = getCachedCorrespondingHost(to: host)
        localHost.setRoomIdForUnregisteredChannel(roomId)
        addOrReplace(host: localHost)
    }
    
    func cachedChannel(forRoomId roomId: String) -> Channel? {
        let channels = cachedHosts.flatMap { $0.channels }
        let foundChannels = channels.filter { $0.roomId == roomId }
        
        if foundChannels.count > 0 {
            return foundChannels[0]
        }
        return nil
    }
    
    func clearUserLoginTokens() {
        // Clear tokens in our hosts
        cachedHosts = cachedHosts.map({ (host: Host) -> Host in
            var updatedHost = host
            updatedHost.credentials?.liveChatUserLoginToken = nil
            return updatedHost
        })
        
        // Clear tokens in the hosts of our socket managers
        let savedConnections = openConnections
        for (host, socketManager) in savedConnections {
            socketManager.host = cachedHost(for: host.url) ?? host
            openConnections[host] = socketManager
        }
    }
    
    func archivedChannels() -> [Channel] {
        let allChannels = cachedHosts.flatMap { $0.channels }
        let openChannels = allChannels.filter { $0.isClosed == true }
        let openChannelsWithHost = openChannels.filter { HostConnectionManager.shared.cachedActiveHost(for: $0) != nil }
        return openChannelsWithHost
    }
    
    func hasRoom(with id: String) -> Bool {
        let foundChannels = getCachedOpenChannels().filter { $0.roomId == id }
        return foundChannels.count > 0
    }
    
    
    // MARK: Private
    
    private static func retrieveHostList(_ completion: @escaping HostRetrievalCompletionClosure) {
        AwsBackendManager.getHostList { (hosts: [Host]?) in
            var updatedHosts = hosts
            if let _ = ProcessInfo.processInfo.environment["USE_INTERNAL_ROCKETCHAT"] {
//                let internalTestHost = Host(url: "http://ec2-54-246-237-82.eu-west-1.compute.amazonaws.com:3001/", socketUrl: "ws://ec2-54-246-237-82.eu-west-1.compute.amazonaws.com:3001/websocket", name: "Internal Test", liveChatToken: "1234567890", credentials: nil)
//                updatedHosts?.append(internalTestHost)
                
//                let pushTest = Host(url: "http://ec2-54-194-163-137.eu-west-1.compute.amazonaws.com:3001/", socketUrl: "ws://ec2-54-194-163-137.eu-west-1.compute.amazonaws.com:3001/websocket", name: "Push Test", liveChatToken: "0987654321", credentials: nil)
//                updatedHosts?.append(pushTest)
                
//                let testServer = Host(url: "http://support.journey-concierge.com:3001/", socketUrl: "ws://support.journey-concierge.com:3001/websocket", name: "support.reisebuddy.com", liveChatToken: "0987654321", credentials: nil)
//                updatedHosts?.append(testServer)
            }
            completion(updatedHosts ?? [])
        }
    }
    
    private func addOrReplace(host: Host) {
        var updatedHosts = cachedHosts
        if let index = updatedHosts.index(of: host) {
            updatedHosts.remove(at: index)
            updatedHosts.insert(host, at: index)
        } else {
            updatedHosts.append(host)
        }
        
        set(cachedHosts: updatedHosts, persist: true)
    }
    
    private func getCachedCorrespondingHost(to host: Host) -> Host {
        for localHost in cachedHosts where localHost == host {
            return localHost
        }
        fatalError("Could not find corresponding host!")
    }
    
    private func host(in hosts: [Host], havingUrl url: String) -> Host? {
        let foundHosts = hosts.filter { $0.url == url }
        if foundHosts.count > 0 {
            return foundHosts[0]
        }
        return nil
    }
    
    private func openHosts(in hosts: [Host]) -> [Host] {
        return hosts.filter { $0.isActive == true }
    }
    
    private func set(cachedHosts newHosts: [Host], persist: Bool) {
        cachedHosts = newHosts
        if persist {
            CacheManager.saveHosts(newHosts)
        }
    }
    
}
