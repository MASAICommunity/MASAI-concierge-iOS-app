//
//  SocketConnectionCheck.swift
//  masai
//
//  Created by Florian Rath on 20.09.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import Starscream


class SocketConnectionCheck {
    
    // MARK: Properties
    
    private static let secondsBetweenConnectionChecks = Double(1)
    private var queue: OperationQueue!
    private var retryCount = 0
    private var retries: Int!
    private var socket: WebSocket!
    private var completionBlock: SocketManager.SocketManagerConnectionCompletion!
    
    
    // MARK: Public
    
    func check(socket: WebSocket, retries: Int = 15, completion: @escaping SocketManager.SocketManagerConnectionCompletion) {
        resetValues()
        
        completionBlock = completion
        self.socket = socket
        self.retries = retries
        
        enqueueRetry()
    }
    
    
    // MARK: Private
    
    private func complete(didSucceed: Bool) {
        resetValues()
        
        DispatchQueue.main.async { [unowned self] in
            self.completionBlock(self.socket, didSucceed)
            self.completionBlock = nil
        }
    }
    
    private func resetValues() {
        if queue != nil {
            queue.cancelAllOperations()
        }
        queue = OperationQueue()
        retryCount = 0
    }
    
    private func enqueueRetry() {
        let operation = BlockOperation(block: { [unowned self] in
            if self.socket.isConnected {
                self.complete(didSucceed: true)
                return
            }
            
            self.retryCount += 1
            if self.retryCount < self.retries {
                DispatchQueue.main.asyncAfter(deadline: .now() + SocketConnectionCheck.secondsBetweenConnectionChecks, execute: {
                    self.enqueueRetry()
                })
            } else {
                self.complete(didSucceed: false)
            }
        })
        
        queue.addOperation(operation)
    }
    
}
