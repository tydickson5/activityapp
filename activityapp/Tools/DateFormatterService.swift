//
//  DateFormatter.swift
//  caravyn
//
//  Created by Ty Dickson on 8/21/26.
//

import Foundation

struct DateFormatterService {
    
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
}
