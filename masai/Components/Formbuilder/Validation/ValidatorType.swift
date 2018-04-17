//
//  ValidatorType.swift
//  masai
//
//  Created by Florian Rath on 16.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation


protocol ValidatorType {
    
    var validateImmediately: Bool { get }
    func isValid(value: String?) -> Bool
    
}


extension ValidatorType {
    
    var validateImmediately: Bool {
        return false
    }
    
}
