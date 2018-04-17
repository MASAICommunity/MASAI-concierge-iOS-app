//
//  PhoneNumberValidator.swift
//  masai
//
//  Created by Florian Rath on 17.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import PhoneNumberKit


class PhoneNumberValidator: ValidatorType {
    
    let phoneNumberKit = PhoneNumberKit()
    
    private var _validateImmediately: Bool
    
    init(validateImmediately: Bool = false) {
        _validateImmediately = validateImmediately
    }
    
    var validateImmediately: Bool {
        return _validateImmediately
    }
    
    func isValid(value: String?) -> Bool {
        guard let val = value else {
            return true
        }
        
        do {
            _ = try phoneNumberKit.parse(val)
            return true
        } catch {
            return false
        }
    }
    
}
