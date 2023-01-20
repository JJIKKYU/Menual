//
//  SpecificDayMomentsModel.swift
//  Menual
//
//  Created by 정진균 on 2022/12/22.
//

import Foundation

public struct SpecificDayMomentsModel {
    // MMdd
    public var monthDay: String
    public var title: [String]
    
    public init(monthDay: String, title: [String]) {
        self.monthDay = monthDay
        self.title = title
    }
}
