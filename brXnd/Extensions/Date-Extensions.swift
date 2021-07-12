//
//  Date-Extensions.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-18.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

extension Date {
	func years(sinceDate: Date) -> Int? {
		return Calendar.current.dateComponents([.year], from: sinceDate, to: self).year
	}

	func months(sinceDate: Date) -> Int? {
		return Calendar.current.dateComponents([.month], from: sinceDate, to: self).month
	}

	func days(sinceDate: Date) -> Int? {
		return Calendar.current.dateComponents([.day], from: sinceDate, to: self).day
	}

	func hours(sinceDate: Date) -> Int? {
		return Calendar.current.dateComponents([.hour], from: sinceDate, to: self).hour
	}

	func minutes(sinceDate: Date) -> Int? {
		return Calendar.current.dateComponents([.minute], from: sinceDate, to: self).minute
	}

	func seconds(sinceDate: Date) -> Int? {
		return Calendar.current.dateComponents([.second], from: sinceDate, to: self).second
	}
}

extension String {

	static func mediumDateShortTime(date: Date) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = .current
		dateFormatter.timeStyle = .short
		dateFormatter.dateStyle = .medium
		return dateFormatter.string(from: date)
	}

	static func mediumDateNoTime(date: Date) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = .current
		dateFormatter.timeStyle = .none
		dateFormatter.dateStyle = .medium
		return dateFormatter.string(from: date)
	}

	static func fullDate(date: Date) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = .current
		dateFormatter.timeStyle = .none
		dateFormatter.dateStyle = .full
		return dateFormatter.string(from: date)
	}
}
