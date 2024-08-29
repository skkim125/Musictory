//
//  DateFormatter+Extension.swift
//  Musictory
//
//  Created by 김상규 on 8/21/24.
//

import Foundation

extension DateFormatter {
    static func convertDateString(_ dateString: String) -> String {
        
        let isoDate = dateString
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = dateFormatter.date(from: isoDate) {
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MM월 dd일"// HH시"
            let formattedDate = outputFormatter.string(from: date)
            
            return formattedDate
        } else {
            return "Invalid date format"
        }
    }
}
