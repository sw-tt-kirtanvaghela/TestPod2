//
//  Date+Extension.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/23/21.
//

import Foundation

extension Date {
    func toString(fromDateTime datetime: Date?) -> String {
        // Purpose: Return a string of the specified date-time in UTC (Zulu) time zone in ISO 8601 format.
        // Example: 2013-10-25T06:59:43.431Z
        let dateFormatter = DateFormatter()
        if let anAbbreviation = NSTimeZone(abbreviation: "UTC") {
            dateFormatter.timeZone = anAbbreviation as TimeZone
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        var dateTimeInIsoFormatForZuluTimeZone: String? = nil
        if let aDatetime = datetime {
            dateTimeInIsoFormatForZuluTimeZone = dateFormatter.string(from: aDatetime)
        }
        return dateTimeInIsoFormatForZuluTimeZone!
    }
}
