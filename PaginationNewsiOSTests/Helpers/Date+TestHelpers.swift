//
//  Date+TestHelpers.swift
//  PaginationNewsiOSTests
//
//  Created by Shinzan Takata on 2020/10/11.
//

import Foundation

extension Date {
    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}

