//
//  EmailValidator.swift
//  masai
//
//  Created by Florian Rath on 16.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation


class EmailValidator: ValidatorType {
    
    private var _validateImmediately: Bool
    
    init(validateImmediately: Bool = false) {
        _validateImmediately = validateImmediately
    }
    
    var validateImmediately: Bool {
        return _validateImmediately
    }
    
    func isValid(value: String?) -> Bool {
        guard let val = value else {
            return false
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: val)
    }
    
}
