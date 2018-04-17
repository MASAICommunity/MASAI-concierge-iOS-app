//
//  ReachabilityManager.swift
//  masai
//
//  Created by Florian Rath on 09.10.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import Alamofire


class ReachabilityManager {
    
    // MARK: Singleton
    
    static let shared = ReachabilityManager()
    
    
    // MARK: Properties
    
    var isOnline = false
    
    private let reachability = NetworkReachabilityManager()
    
    
    // MARK: Lifecycle
    
    init() {
        startListening()
    }
    
    
    // MARK: Private
    
    private func startListening() {
        reachability?.listener = { [unowned self] status in
            switch status {
            case .notReachable:
                self.isOnline = false
                
            case .unknown :
                break
                
            case .reachable(.ethernetOrWiFi): fallthrough
            case .reachable(.wwan):
                self.isOnline = true
            }
        }
        
        reachability?.startListening()
    }
    
}
