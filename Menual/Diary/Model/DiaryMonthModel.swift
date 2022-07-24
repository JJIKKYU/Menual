//
//  DiaryMonthModel.swift
//  Menual
//
//  Created by 정진균 on 2022/06/06.
//

import Foundation

// MARK: - My Menual에서 달/연도마다 얼마나 썼는지 담는 모델
public struct DiaryMonthModel {
    var monthCount: Int = 0 {
        didSet {
            print("monthCount! = \(oldValue)")
        }
    }
    var allCount: Int = 0 {
        didSet {
            print("allCount = \(oldValue)")
        }
    }

    var jan: Int = 0
    var fab: Int = 0
    var mar: Int = 0
    var apr: Int = 0
    var may: Int = 0
    var jun: Int = 0
    var jul: Int = 0
    var aug: Int = 0
    var sep: Int = 0
    var oct: Int = 0
    var nov: Int = 0
    var dec: Int = 0
    
    mutating func updateAllCount() {
        allCount += 1
    }
    
    mutating func updateCount(MM: String) {
        switch MM {
        case "01":
            if jan == 0 { monthCount += 1 }
            jan += 1
        case "02":
            if fab == 0 { monthCount += 1 }
            fab += 1
        case "03":
            if mar == 0 { monthCount += 1 }
            mar += 1
        case "04":
            if apr == 0 { monthCount += 1 }
            apr += 1
        case "05":
            if may == 0 { monthCount += 1 }
            may += 1
        case "06":
            if jun == 0 { monthCount += 1 }
            jun += 1
        case "07":
            if jul == 0 { monthCount += 1 }
            jul += 1
        case "08":
            if aug == 0 { monthCount += 1 }
            aug += 1
        case "09":
            if sep == 0 { monthCount += 1 }
            sep += 1
        case "10":
            if oct == 0 { monthCount += 1 }
            oct += 1
        case "11":
            if nov == 0 { monthCount += 1 }
            nov += 1
        case "12":
            if dec == 0 { monthCount += 1 }
            dec += 1
        default:
            break
        }
    }
    
    func getMenualCountWithMonth(MM: String) -> Int {
        let mm: String = MM.lowercased()
        switch mm {
        case "jan":
            return jan
        case "fab":
            return fab
        case "mar":
            return mar
        case "apr":
            return apr
        case "may":
            return may
        case "jun":
            return jun
        case "jul":
            return jul
        case "aug":
            return aug
        case "sep":
            return sep
        case "oct":
            return oct
        case "nov":
            return nov
        case "dec":
            return dec
        default:
            return 0
        }
    }
    
    func getArr() -> [Int] {
        var arr: [Int] = []
        if jan != 0 { arr.append(jan) }
        if fab != 0 { arr.append(fab) }
        if mar != 0 { arr.append(mar) }
        if apr != 0 { arr.append(apr) }
        if may != 0 { arr.append(may) }
        if jun != 0 { arr.append(jun) }
        if jul != 0 { arr.append(jul) }
        if aug != 0 { arr.append(aug) }
        if sep != 0 { arr.append(sep) }
        if oct != 0 { arr.append(oct) }
        if nov != 0 { arr.append(nov) }
        if dec != 0 { arr.append(dec) }
        
        print("Arr = \(arr)")
        
        return arr
    }
    
    func getMonthArr() -> [String] {
        var arr: [String] = []
        if dec != 0 { arr.append("DEC") }
        if nov != 0 { arr.append("NOV") }
        if oct != 0 { arr.append("OCT") }
        if sep != 0 { arr.append("SEP") }
        if aug != 0 { arr.append("AUG") }
        if jul != 0 { arr.append("JUL") }
        if jun != 0 { arr.append("JUN") }
        if may != 0 { arr.append("MAY") }
        if apr != 0 { arr.append("APR") }
        if mar != 0 { arr.append("MAR") }
        if fab != 0 { arr.append("FAB") }
        if jan != 0 { arr.append("JAN") }
        
        return arr
    }
}

public struct DiaryYearModel {
    let year: Int
    var months: DiaryMonthModel?
}
