//
//  AlarmWeekdaysModel.swift
//  Menual
//
//  Created by 정진균 on 2023/07/29.
//

import Foundation

public enum Weekday: String, CaseIterable, Equatable {
    case monday = "월"
    case tuesday = "화"
    case wednesday = "수"
    case thursday = "목"
    case friday = "금"
    case saturday = "토"
    case sunday = "일"

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
    
    // 정수값을 Weekday enum으로 변환하는 함수
    public static func fromInt(_ intValue: Int) -> Weekday? {
        switch intValue {
        case 0:
            return .monday
        case 1:
            return .tuesday
        case 2:
            return .wednesday
        case 3:
            return .thursday
        case 4:
            return .friday
        case 5:
            return .saturday
        case 6:
            return .sunday
        default:
            return nil
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
