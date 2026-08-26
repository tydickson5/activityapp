//
//  DateFormatter.swift
//  caravyn
//
//  Created by Ty Dickson on 8/21/26.
//

import Foundation

struct DateFormatterService {
    
    //to supabase
    func formattedDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: isoString) else {
            return isoString
        }

        let output = DateFormatter()
        output.dateStyle = .medium
        output.timeStyle = .short

        return output.string(from: date)
    }
    
    func dateFromSupabase(_ isoString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let formats = [
            "yyyy-MM-dd HH:mm:ss.SSSSSZ",
            "yyyy-MM-dd HH:mm:ss.SSSSS'+00'",
            "yyyy-MM-dd HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
            "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        ]

        for format in formats {
            formatter.dateFormat = format

            if let date = formatter.date(from: isoString) {
                return date
            }
        }

        print("Failed to parse Supabase date:", isoString)
        return nil
    }
    
    func supabaseDateString(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        return formatter.string(from: date)
    }
}
