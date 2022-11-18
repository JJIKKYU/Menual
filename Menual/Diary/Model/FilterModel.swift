//
//  FilterModel.swift
//  Menual
//
//  Created by 정진균 on 2022/11/19.
//

import Foundation

enum FilterType {
    case dateFilter
    case filter
}

struct FilterModel {
    var isEnabled: Bool
    var filterType: FilterType
}
