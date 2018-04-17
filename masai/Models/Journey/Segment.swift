//
//  Segment.swift
//
//  Created by Florian Rath on 27.08.17
//  Copyright (c) Codepool GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON


public protocol Segment {
    
    init(object: Any)
    
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    init(json: JSON)
    
    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    func dictionaryRepresentation() -> [String: Any]
    
    var userFacingStartDateString: String? { get }
    var userFacingStartTimeString: String? { get }
    var userFacingEndDateString: String? { get }
    var userFacingEndTimeString: String? { get }
    
}

class SegmentFactory {
    
    static func segment(from json: JSON) -> Segment? {
        
        guard let type = json["type"].string else {
            return nil
        }
        
        if type == "Air" {
            return FlightSegment(json: json)
        } else if type == "Car" {
            return CarSegment(json: json)
        } else if type == "Hotel" {
            return HotelSegment(json: json)
        } else if type == "Rail" {
            return TrainSegment(json: json)
        } else if type == "Activity" {
            return ActivitySegment(json: json)
        }
        
        return nil
    }
    
    static let backendDateFormatters: [DateFormatter] = {
        let formatters: [DateFormatter] = [
        {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return df
            }(),
        {
            let dateFormatter = DateFormatter()
            let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
            dateFormatter.locale = enUSPosixLocale
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            return dateFormatter
            }(),
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter
            }(),
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter
            }()
        ]
        return formatters
    }()
    
    static let userFacingDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    
    static let userFacingTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()
    
    static func dateTimeFrom(backendDateString dateString: String?) -> (String, String)? {
        guard let dateString = dateString else {
            return nil
        }
        
        guard let date = dateFromBackend(dateString: dateString) else {
            return nil
        }
        
        let formattedDateString = SegmentFactory.userFacingDateFormatter.string(from: date)
        let formattedTimeString = SegmentFactory.userFacingTimeFormatter.string(from: date)
        
        return (formattedDateString, formattedTimeString)
    }
    
    static func dateFromBackend(dateString: String) -> Date? {
        var date: Date?
        for formatter in SegmentFactory.backendDateFormatters {
            date = formatter.date(from: dateString)
            if date != nil {
                break
            }
        }
        
        assert(date != nil, "Seems like an unknown date format came from the backend!")
        
        return date
    }
    
}
