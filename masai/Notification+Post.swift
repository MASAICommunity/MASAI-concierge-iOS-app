//
//  Notification+Post.swift
//  masai
//
//  Created by Florian Rath on 05.11.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation


extension Notification {
    
    // MARK: Types
    
    typealias NotificationToken = NSObjectProtocol
    typealias EventClosure = (_ receivedNotification: Notification) -> Void
    
    
    // MARK: Posting
    
    func post(in notificationCenter: NotificationCenter = NotificationCenter.default) {
        notificationCenter.post(self)
    }
    
    
    // MARK: Receiving
    
    func observe(object: Any? = nil, queue: OperationQueue = OperationQueue.main, notificationCenter: NotificationCenter = NotificationCenter.default, eventClosure: @escaping EventClosure) -> NotificationToken {
        return notificationCenter.addObserver(forName: self.name, object: object, queue: queue, using: eventClosure)
    }
    
}
