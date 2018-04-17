//
//  Date+Utils.swift
//  masai
//
//  Created by Bartomiej Burzec on 06.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation

extension Date {
    
    private static func isoFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        
        return dateFormatter
    }
    
    private static func shortDayFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'Z"
        
        return dateFormatter
    }
    
    private static func reservationDateForrmater() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "Ed.MMM.yyyy"
        return dateFormatter
    }
    
    private static func timeDateForrmater() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter

    }
    
    public static func dateFromMasaiTimestamp(_ timestamp: Double?) -> Date? {
        guard let interval = timestamp else {
            return nil
        }
        return Date(timeIntervalSince1970: interval / 1000)
    }
    
    public static func masaiTimestampFromDate(_ date: Date) -> Double {
        return date.timeIntervalSince1970 * 1000
    }
    
    public func shortString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
    
    public static func dateDayFormat(_ string: String?) -> Date? {
        if let string = string {
            let forrmater = shortDayFormatter()
            return forrmater.date(from: string)
        }
        return nil
    }
    
    public static func dayDateString(_ date: Date) -> String {
        let formatter = shortDayFormatter()
        return formatter.string(from: date)
    }
    
    public static func dateWithFullFormat(_ string: String?) -> Date? {
        if let string = string {
            let forrmater = isoFormatter()
            return forrmater.date(from: string)
        }
        return nil
    }
    
    public static func reservationDateString(_ date: Date) -> String? {
        let formatter = reservationDateForrmater()
        return formatter.string(from: date)
    }
    
    public static func fullDateString(_ date: Date) -> String {
        let formatter = isoFormatter()
        return formatter.string(from: date)
        
    }
    
    public static func timeString(_ date: Date) -> String {
        let forrmater = timeDateForrmater()
        return forrmater.string(from: date)
    }
    
    public func timeDifference() -> String? {
        let calendar = Calendar.current
        let minutes = calendar.dateComponents([.minute], from: self, to: Date()).minute
        let days = calendar.dateComponents([.day], from: self, to: Date()).day
        let hours = calendar.dateComponents([.hour], from: self, to: Date()).hour
        
        if let minutes = minutes, let days = days, let hours = hours {
            if minutes < 1 {
                return "just_now".localized
            }
            if minutes < 2 {
                return "a_minute_ago".localized
            }
            if minutes < 60 {
                return String(format: "some_minutes_ago".localized, minutes)
            }
            if hours < 24 {
                return String(format: "some_hours_ago".localized, hours)
            }
            if hours < 48 {
                return "yesterday".localized
            }
            return String(format: "some_days_ago".localized, days)

        }
        
        return nil
    }
    
    public static func daysBetween(start: Date?, end: Date?) -> Int {
        
        if let start = start, let end = end {
            let currentCalendar = Calendar.current
            guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else { return 0 }
            guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else { return 0 }
            
            return end - start
        }
        return 0
    }

}
