//
//  DateFormatter+Formats.swift
//  Receiptie
//
//  Created by Tanner Bennett on 3/30/22.
//  Copyright © 2022 Tanner Bennett. All rights reserved.
//

import Foundation

extension DateFormatter {
    private static let shared = DateFormatter()
    
    enum Format: String {
        case american = "MM/dd/yyyy"
        case homeList = "MMM d, yyyy, h:mm a"
    }
    
    static func string(from date: Date?, format: Format) -> String {
        guard let date = date else { return "undated" }
        
        self.shared.dateFormat = format.rawValue
        return self.shared.string(from: date)
    }
    
    static func date(from string: String?, format: Format) -> Date? {
        guard let string = string else { return nil }
        
        self.shared.dateFormat = format.rawValue
        return self.shared.date(from: string)
    }
}
