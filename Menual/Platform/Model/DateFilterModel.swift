//
//  DateFilterModel.swift
//  Menual
//
//  Created by 정진균 on 2022/11/25.
//

import Foundation

struct DateFilterModel {
    var year: Int
    var months: [DateFilterMonthsModel]
}

struct DateFilterMonthsModel {
    var month: Int
    var diaryCount: Int
}

// [2022.11] = [다이어리1, 다이어리2]
// [2022.12] = [다이어리1, 다이어리2, 다이어리3]
