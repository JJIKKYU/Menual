//
//  AlarmWeekdaysModel.swift
//  Menual
//
//  Created by 정진균 on 2023/07/29.
//

import Foundation

public enum Weekday: String, CaseIterable {
    case monday = "월요일"
    case tuesday = "화요일"
    case wednesday = "수요일"
    case thursday = "목요일"
    case friday = "금요일"
    case saturday = "토요일"
    case sunday = "일요일"

    var intValue: Int {
        switch self {
        case .monday:
            return 0
        case .tuesday:
            return 1
        case .wednesday:
            return 2
        case .thursday:
            return 3
        case .friday:
            return 4
        case .saturday:
            return 5
        case .sunday:
            return 6
        }
    }

    public func transformIntWeekday() -> Int {
        return self.intValue
    }

    // '월~일'을 리턴하는 함수
    public static func getWeekdays() -> [Weekday] {
        return [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
}
