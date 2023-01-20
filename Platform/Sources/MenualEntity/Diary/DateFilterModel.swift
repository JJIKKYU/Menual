//
//  DateFilterModel.swift
//  Menual
//
//  Created by 정진균 on 2022/11/25.
//

import Foundation

public struct DateFilterModel {
    public var year: Int
    public var months: [DateFilterMonthsModel]
    
    public init(year: Int, months: [DateFilterMonthsModel]) {
        self.year = year
        self.months = months
    }
}

public struct DateFilterMonthsModel {
    public var month: Int
    public var diaryCount: Int
    
    public init(month: Int, diaryCount: Int) {
        self.month = month
        self.diaryCount = diaryCount
    }
}

// [2022.11] = [다이어리1, 다이어리2]
// [2022.12] = [다이어리1, 다이어리2, 다이어리3]
