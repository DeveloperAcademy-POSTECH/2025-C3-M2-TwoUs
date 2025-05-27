//
//  Date+.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import Foundation

extension Date {
    /// 날짜를 "MM.dd" 형태로 반환하는 포맷
    var toMonthDayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM.dd"
        return formatter.string(from: self)
    }
}
