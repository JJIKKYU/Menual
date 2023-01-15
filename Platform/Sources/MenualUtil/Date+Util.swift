//
//  Date+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/05/28.
//

import Foundation

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter.string(from: self)
    }
    
    func toStringHourMin() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter.string(from: self)
    }
    
    func toStringWithHourMin() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter.string(from: self)
    }
    
    func toStringWithMM() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter.string(from: self)
    }
    
    func toStringWithYYYY() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter.string(from: self)
    }
    
    func toStringWithYYYYMM() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter.string(from: self)
    }
    
    func toStringWithMMdd() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter.string(from: self)
    }
    
    func toStringWithMonthEngName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        switch dateFormatter.string(from: self) {
        case "01":
            return "JAN"
        case "02":
            return "FAB"
        case "03":
            return "MAR"
        case "04":
            return "APR"
        case "05":
            return "MAY"
        case "06":
            return "JUN"
        case "07":
            return "JUL"
        case "08":
            return "AUG"
        case "09":
            return "SEP"
        case "10":
            return "OCT"
        case "11":
            return "NOV"
        case "12":
            return "DEC"
        default:
            return ""
        }
    }
}

extension String {
    func convertEngMonthName() -> String {
        switch self {
        case "01", "1":
            return "JAN"
        case "02", "2":
            return "FAB"
        case "03", "3":
            return "MAR"
        case "04", "4":
            return "APR"
        case "05", "5":
            return "MAY"
        case "06", "6":
            return "JUN"
        case "07", "7":
            return "JUL"
        case "08", "8":
            return "AUG"
        case "09", "9":
            return "SEP"
        case "10":
            return "OCT"
        case "11":
            return "NOV"
        case "12":
            return "DEC"
        default:
            return ""
        }
    }
    
    func convertMonthName() -> String {
        switch self {
        case "JAN":
            return "01"
        case "FAB":
            return "02"
        case "MAR":
            return "03"
        case "APR":
            return "04"
        case "MAY":
            return "05"
        case "JUN":
            return "06"
        case "JUL":
            return "07"
        case "AUG":
            return "08"
        case "SEP":
            return "09"
        case "OCT":
            return "10"
        case "NOV":
            return "11"
        case "DEC":
            return "12"
        default:
            return ""
        }
    }
}

// MARK: - Custom Calndar 제작을 위한 extension
extension Date {
    var weekday: Int {
        get {
            Calendar.current.component(.weekday, from: self)
        }
    }
    
    var fistDayOfTheMonth: Date {
        get {
            Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        }
    }
}

extension String {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var date: Date? {
        String.dateFormatter.date(from: self)
    }
}

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}
