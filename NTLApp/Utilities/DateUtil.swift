//
//  DateUtil.swift
//  NTLApp
//
//  Created by Tripsdoc on 14/08/23.
//

import Foundation

func getDate(modifier: Int, format: String = "yyyy-MM-dd") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = format
    let now = Date()
    let dayFromNow = Calendar.current.date(byAdding: .day, value: modifier, to: now)
    return dateFormatter.string(from: dayFromNow!)
}

func dateFromString(strDate: String, format: String = "dd-MM-yy") -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: strDate)
}

func dateToString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
}

func getFileName() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
    let now = Date()
    let dayFromNow = Calendar.current.date(byAdding: .day, value: 0, to: now)
    return dateFormatter.string(from: dayFromNow!)
}
