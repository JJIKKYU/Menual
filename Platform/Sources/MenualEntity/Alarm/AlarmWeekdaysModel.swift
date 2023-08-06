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
        case .sunday:
            return 1
        case .monday:
            return 2
        case .tuesday:
            return 3
        case .wednesday:
            return 4
        case .thursday:
            return 5
        case .friday:
            return 6
        case .saturday:
            return 7
        }
    }
    
    // 정수값을 Weekday enum으로 변환하는 함수
    public static func fromInt(_ intValue: Int) -> Weekday? {
        switch intValue {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
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
