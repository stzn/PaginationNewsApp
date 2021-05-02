//
//  Date+Adding.swift
//  PaginationNews
//
//  Created by Shinzan Takata on 2021/05/02.
//

import Foundation

public extension Date {
	func adding(seconds: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
		return calendar.date(byAdding: .second, value: seconds, to: self)!
	}

	func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
		return calendar.date(byAdding: .minute, value: minutes, to: self)!
	}

	func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
		return calendar.date(byAdding: .day, value: days, to: self)!
	}
}
