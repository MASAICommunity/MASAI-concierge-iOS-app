//
//  JourneyMockJson.swift
//  masai
//
//  Created by Florian Rath on 27.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation


struct JourneyMockJson {
    
    static func jsonString() -> String {
        guard let path = Bundle.main.path(forResource: "journey_mocks", ofType: "json") else {
            return ""
        }
        
        let url = URL(fileURLWithPath: path)
        
        let jsonData: Data
        do {
            jsonData = try Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
        } catch {
            return ""
        }
        
        var string = String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
        
        string = string.replacingOccurrences(of: "\t", with: "")
        string = string.replacingOccurrences(of: "\n", with: "")
        
        return string
    }
    
}
