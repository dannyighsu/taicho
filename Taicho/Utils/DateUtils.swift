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
        let dateformat = DateFormatter()
        dateformat.dateStyle = .medium
        dateformat.timeStyle = .long
        dateformat.timeZone = timezone
        return dateformat.string(from: date)
    }
    
}
