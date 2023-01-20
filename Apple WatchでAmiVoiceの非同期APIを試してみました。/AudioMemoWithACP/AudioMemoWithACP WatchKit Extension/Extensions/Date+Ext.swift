//
//  Date+Ext.swift
//  AudioMemoWithACP WatchKit Extension
//
//  Created by 林 政樹 on 2021/10/08.
//

import Foundation

extension Date {
    //
    func toString(_ format: String = "yyyy/MM/dd HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        return formatter.string(from: self)
    }
}
