//
//  WebSocket+Utils.swift
//  masai
//
//  Created by Bartomiej Burzec on 01.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import Starscream

private struct AssociatedKeys {
    static var reconnecting = "reconnectig"
}

extension WebSocket {
    
    func key() -> String {
        return self.currentURL.absoluteString
    }
    
    
    var reconnecting : Bool {
        get {
            guard let number = objc_getAssociatedObject(self, &AssociatedKeys.reconnecting) as? NSNumber else {
                return false
            }
            return number.boolValue
        }
        
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.reconnecting,NSNumber(value: value),objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
}
