//
//  Date+Extension.swift
//  SimpleCalorie
//
//  Created by Lev Litvak on 20.05.2022.
//

import Foundation

extension Date {
    static func from(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
        let dateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        let calendar = Calendar.current
        
        return calendar.date(from: dateComponents) ?? Date()
    }
    
    func beginningOfTheDay() -> Date {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)

        return Calendar.current.date(from: dateComponents)!
    }
    
    func endOfTheDay() -> Date {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        dateComponents.hour = 23
        dateComponents.minute = 59
        dateComponents.second = 59
        
        return Calendar.current.date(from: dateComponents)!
    }
    
    func subtract(monthCount: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: -monthCount, to: self)!
    }
    
    func subtract(daysCount: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -daysCount, to: self)!
    }
    
    func toString(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle

        dateFormatter.locale = Locale.current

        return dateFormatter.string(from: self)
    }
    
    func toTimeString() -> String {
        return self.toString(dateStyle: .none, timeStyle: .short)
    }
}
