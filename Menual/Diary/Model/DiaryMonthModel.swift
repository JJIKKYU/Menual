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
    var janDiary: [DiaryModel] = []

    var fab: Int = 0
    var fabDiary: [DiaryModel] = []
    
    var mar: Int = 0
    var marDiary: [DiaryModel] = []
    
    var apr: Int = 0
    var aprDiary: [DiaryModel] = []
    
    var may: Int = 0
    var mayDiary: [DiaryModel] = []
    
    var jun: Int = 0
    var junDiary: [DiaryModel] = []
    
    var jul: Int = 0
    var julDiary: [DiaryModel] = []
    
    var aug: Int = 0
    var augDiary: [DiaryModel] = []
    
    var sep: Int = 0
    var sepDiary: [DiaryModel] = []
    
    var oct: Int = 0
    var octDiary: [DiaryModel] = []
    
    var nov: Int = 0
    var novDiary: [DiaryModel] = []
    
    var dec: Int = 0
    var decDiary: [DiaryModel] = []
    
    mutating func updateAllCount() {
        allCount += 1
    }
    
    mutating func updateCount(MM: String, diary: DiaryModel) {
        print("updatecount :: diary = \(diary)")
        switch MM {
        case "01":
            // if jan == 0 { monthCount += 1 }
            jan += 1
            janDiary.append(diary)
        case "02":
            // if fab == 0 { monthCount += 1 }
            fab += 1
            fabDiary.append(diary)
        case "03":
            // if mar == 0 { monthCount += 1 }
            mar += 1
            marDiary.append(diary)
        case "04":
            // if apr == 0 { monthCount += 1 }
            apr += 1
            aprDiary.append(diary)
        case "05":
            // if may == 0 { monthCount += 1 }
            may += 1
            mayDiary.append(diary)
        case "06":
            // if jun == 0 { monthCount += 1 }
            jun += 1
            junDiary.append(diary)
        case "07":
            // if jul == 0 { monthCount += 1 }
            jul += 1
            julDiary.append(diary)
        case "08":
            // if aug == 0 { monthCount += 1 }
            aug += 1
            augDiary.append(diary)
        case "09":
            // if sep == 0 { monthCount += 1 }
            sep += 1
            sepDiary.append(diary)
        case "10":
            // if oct == 0 { monthCount += 1 }
            oct += 1
            octDiary.append(diary)
        case "11":
            // if nov == 0 { monthCount += 1 }
            nov += 1
            novDiary.append(diary)
        case "12":
            // if dec == 0 { monthCount += 1 }
            dec += 1
            decDiary.append(diary)
        default:
            break
        }
    }
    
    mutating func sortDiary() {
        janDiary.sort { $0.createdAt > $1.createdAt }
        fabDiary.sort { $0.createdAt > $1.createdAt }
        marDiary.sort { $0.createdAt > $1.createdAt }
        aprDiary.sort { $0.createdAt > $1.createdAt }
        mayDiary.sort { $0.createdAt > $1.createdAt }
        junDiary.sort { $0.createdAt > $1.createdAt }
        julDiary.sort { $0.createdAt > $1.createdAt }
        augDiary.sort { $0.createdAt > $1.createdAt }
        sepDiary.sort { $0.createdAt > $1.createdAt }
        octDiary.sort { $0.createdAt > $1.createdAt }
        novDiary.sort { $0.createdAt > $1.createdAt }
        decDiary.sort { $0.createdAt > $1.createdAt }
    }
    
    mutating func filterDiary(weatherTypes: [Weather], placeTypes: [Place]) {
        print("filter 이전 = sepDiary = \(sepDiary)")
        
        // 각 monthsArr를 담아준다
        var monthsArr = [janDiary, fabDiary, marDiary, aprDiary, mayDiary, junDiary, julDiary, augDiary, sepDiary, octDiary, novDiary, decDiary]
        
        for (index, _) in monthsArr.enumerated() {
            var month = monthsArr[index]
            if !weatherTypes.isEmpty {
                month = month.filter {
                    guard let weather = $0.weather?.weather else { return false }
                    if weatherTypes.contains(weather) == true { return true }
                    return false
                }
                monthsArr[index] = month
            }
            
            if !placeTypes.isEmpty {
                month = month.filter {
                    guard let place = $0.place?.place else { return false }
                    if placeTypes.contains(place) == true { return true }
                    return false
                }
                monthsArr[index] = month
            }
        }
        
        setAllDiary(monthsArr: monthsArr)
        
        print("filter 후 = sepDiary = \(sepDiary)")
        // return monthsArr
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
    
    func getMenualArr(MM: String) -> [DiaryModel] {
        let mm: String = MM.lowercased()
        switch mm {
        case "jan":
            return janDiary
        case "fab":
            return fabDiary
        case "mar":
            return marDiary
        case "apr":
            return aprDiary
        case "may":
            return mayDiary
        case "jun":
            return junDiary
        case "jul":
            return julDiary
        case "aug":
            return augDiary
        case "sep":
            return sepDiary
        case "oct":
            return octDiary
        case "nov":
            return novDiary
        case "dec":
            return decDiary
        default:
            return []
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
    
    mutating func setAllDiary(monthsArr: [[DiaryModel]]) {
        print("setAllDiary!")
        janDiary = monthsArr[0]
        jan = monthsArr[0].count
        
        fabDiary = monthsArr[1]
        fab = monthsArr[1].count
        
        marDiary = monthsArr[2]
        mar = monthsArr[2].count
        
        aprDiary = monthsArr[3]
        apr = monthsArr[3].count
        
        mayDiary = monthsArr[4]
        may = monthsArr[4].count
        
        junDiary = monthsArr[5]
        jun = monthsArr[5].count
        
        julDiary = monthsArr[6]
        jul = monthsArr[6].count
        
        augDiary = monthsArr[7]
        aug = monthsArr[7].count
        
        sepDiary = monthsArr[8]
        sep = monthsArr[8].count
        
        octDiary = monthsArr[9]
        oct = monthsArr[9].count
        
        novDiary = monthsArr[10]
        nov = monthsArr[10].count
        
        decDiary = monthsArr[11]
        dec = monthsArr[11].count
        
        allCount = jan + fab + mar + apr + may + jun + jul + aug + sep + oct + nov + dec
        print("allCount = \(allCount)")
    }
}

public struct DiaryYearModel {
    let year: Int
    var months: DiaryMonthModel?
}
