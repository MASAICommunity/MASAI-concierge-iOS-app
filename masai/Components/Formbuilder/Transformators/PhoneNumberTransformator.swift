//
//  PhoneNumberTransformator.swift
//  masai
//
//  Created by Florian Rath on 12.10.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import PhoneNumberKit


class PhoneNumberTransformator: TransformatorType {
    
    static let phoneNumberKit = PhoneNumberKit()
    
    func transform(value: Any?) -> Any? {
        guard let sourceString = value as? String else {
            return value
        }
        
        do {
            let phoneNumber = try PhoneNumberTransformator.phoneNumberKit.parse(sourceString)
            let transformedString = PhoneNumberTransformator.phoneNumberKit.format(phoneNumber, toType: .e164, withPrefix: true)
            return transformedString
        }
        catch {
//            print("Parser error")
            return value
        }
    }
    
}
