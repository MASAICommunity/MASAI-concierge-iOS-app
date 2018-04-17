//
//  AwsBackendError.swift
//  masai
//
//  Created by Florian Rath on 26.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON


enum AwsBackendError: Error {
    
    // MARK: Errors
    
    case unknownError
    case unauthorized
    case unsupportedMediaType
    case validationException
    
    
    // MARK: Public
    
    static func fromJson(json jsonResponse: JSON, httpStatusCode: Int?) -> AwsBackendError? {
        if jsonResponse["message"].string == "Unsupported Media Type" {
            return .unsupportedMediaType
        }
        
        if httpStatusCode == 401 || jsonResponse["message"].string == "Unauthorized" {
            return .unauthorized
        }
        
        if jsonResponse["__type"].string == "com.amazon.coral.validate#ValidationException" {
            print("\(jsonResponse.stringValue)")
            assert(false, "Post payload has a validation exception!")
            return .validationException
        }
        
        let message = jsonResponse["message"].string
        if let _ = message {
            print("\(jsonResponse.stringValue)")
            return .unknownError
        }
        
        return nil
    }
    
}
