//
//  Channel+RealmSwift.swift
//  masai
//
//  Created by Florian Rath on 06.11.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftDate


extension Channel {
    
    // MARK: Public
    
    func contains(searchTerm: String) -> Bool {
        // If we're searching for "", we'll just say our channel contains that message
        guard searchTerm.length > 0 else {
            return true
        }
        
        let filteredMessages = messages()
            .filter { $0.dataType() == .message }
            .filter { $0.messageText?.lowercased().contains(searchTerm.lowercased()) ?? false }
        return filteredMessages.count > 0
    }
    
    func contains(date: Date) -> Bool {
        guard let firstMessage = firstMessage(),
            let firstMessageDate = firstMessage.date,
            let lastMessage = lastMessage(),
            let lastMessageDate = lastMessage.date else {
                return false
        }
        
        let beginningOfFirstDay = firstMessageDate.startOfDay
        let endOfLastDay = lastMessageDate.endOfDay
        
        return beginningOfFirstDay <= date && endOfLastDay >= date
    }
    
    func unsentMessages() -> [ChatMessage] {
        guard let messages = channelMessages()?.filter("sending == NO AND sent == NO") else {
            return []
        }
        return messages.flatMap({ $0 as ChatMessage })
    }
    
    func messages() -> [ChatMessage] {
        guard let messages = channelMessages()?.sorted(byKeyPath: "date", ascending: false) else {
            return [ChatMessage]()
        }
        return messages.flatMap({ $0 as ChatMessage })
    }
    
    func lastMessages(_ from: Date) -> [ChatMessage] {
        guard let messages = channelMessages()?.filter("updated > %@", from as NSDate).sorted(byKeyPath: "date", ascending: true) else {
            return []
        }
        return messages.flatMap({ $0 as ChatMessage })
    }
    
    func lastMessage() -> ChatMessage? {
        if let lastMsg = channelMessages()?.sorted(byKeyPath: "date", ascending: true).flatMap({$0 as ChatMessage}).last {
            return lastMsg
        } else {
            return nil
        }
    }
    
    func firstMessage() -> ChatMessage? {
        if let firstMsg = channelMessages()?.sorted(byKeyPath: "date", ascending: false).flatMap({$0 as ChatMessage}).last {
            return firstMsg
        } else {
            return nil
        }
    }
    
    private func channelMessages() -> Results<ChatMessage>? {
        guard let rid = roomId else {
            return nil
        }
        
        let channelMessages = try? Realm().objects(ChatMessage.self).filter("rid == %@", rid)
        return channelMessages
    }
    
}
