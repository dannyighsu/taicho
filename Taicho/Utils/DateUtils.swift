//
//  DateUtils.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/16/22.
//

import Foundation

struct DateUtils {
    
    static func getDisplayFormat(_ date: Date) -> String {
        let dateformat = DateFormatter()
        dateformat.dateStyle = .medium
        dateformat.timeStyle = .short
        dateformat.locale = Locale.current
        return dateformat.string(from: date)
    }
    
    static func getDisplayFormat(_ date: Date, inTimezone timezone: TimeZone) -> String {
        return getTimezoneDateFormatter(timezone).string(from: date)
    }

    static func getShortDisplay(_ date: Date) -> String {
        let dateformat = DateFormatter()
        dateformat.dateStyle = .short
        dateformat.timeStyle = .short
        dateformat.locale = Locale.current
        return dateformat.string(from: date)
    }
    
    static func getDate(from displayFormattedDate: String) -> Date? {
        let range = NSRange(location: 0, length: displayFormattedDate.count)
        return try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
            .matches(in: displayFormattedDate, range: range)
            .compactMap { $0.date }.first
    }
    
    private static func getTimezoneDateFormatter(_ timezone: TimeZone) -> DateFormatter {
        let dateformat = DateFormatter()
        dateformat.dateStyle = .medium
        dateformat.timeStyle = .long
        dateformat.timeZone = timezone
        return dateformat
    }
    
}
