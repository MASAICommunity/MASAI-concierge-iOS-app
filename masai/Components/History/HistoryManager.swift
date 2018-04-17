//
//  HistoryManager.swift
//  masai
//
//  Created by Florian Rath on 05.11.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation


class HistoryManager {
    
    // MARK: Singleton
    
    static var shared = HistoryManager()
    
    
    // MARK: Properties
    
    private var closeChatToken: Notification.NotificationToken?
    private var socketConnectedToken: Notification.NotificationToken?
    
    
    // MARK: Lifecycle
    
    init() {
        setup()
    }
    
    
    // MARK: Setup
    
    private func setup() {
        closeChatToken = Constants.Notification.closeChannel.observe(eventClosure: { [unowned self] (receivedNotification: Notification) in
            guard let userInfo = receivedNotification.userInfo,
                let channel = userInfo["channel"] as? Channel else {
                    return
            }
            
            // Archive channel to history
            self.archive(channel: channel)
        })
        
        socketConnectedToken = Constants.Notification.socketConnected.observe(eventClosure: { (receivedNotification: Notification) in
            guard let userInfo = receivedNotification.userInfo,
                let host = userInfo["host"] as? Host else {
                    return
            }
            
            // Load history for every channel
            let socketManager = HostConnectionManager.shared.socketManager(for: host)
            let openChannels = HostConnectionManager.shared.getCachedOpenChannels()
            var currentWaitTime = Double(0)
            let timeBetweenCalls = Double(0.5)
            for c in openChannels {
                DispatchQueue.main.asyncAfter(deadline: .now() + currentWaitTime, execute: {
                    socketManager?.loadHistory(for: c)
                })
                currentWaitTime += timeBetweenCalls
            }
        })
    }
    
    
    // MARK: Private
    
    private func archive(channel: Channel) {
        guard let host = HostConnectionManager.shared.cachedActiveHost(for: channel) else {
            assert(false, "Could not get host for channel")
            return
        }
        
        var updatedChannel = channel
        updatedChannel.isClosed = true
        HostConnectionManager.shared.addOrReplace(channel: updatedChannel, to: host)
    }
}
