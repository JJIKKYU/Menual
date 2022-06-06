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
        dateFormatter.timeZone = TimeZone(identifier: "KST")
        return dateFormatter.string(from: self)
    }
    
    func toStringWithHourMin() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "KST")
        return dateFormatter.string(from: self)
    }
    
    func toStringWithMM() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        dateFormatter.timeZone = TimeZone(identifier: "KST")
        return dateFormatter.string(from: self)
    }
    
    func toStringWithYYYY() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        dateFormatter.timeZone = TimeZone(identifier: "KST")
        return dateFormatter.string(from: self)
    }
    
    func toStringWithMonthEngName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        dateFormatter.timeZone = TimeZone(identifier: "KST")
        
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
