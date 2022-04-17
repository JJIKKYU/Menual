//
//  DiarySubDataModel.swift
//  Menual
//
//  Created by 정진균 on 2022/04/17.
//

import Foundation
import RealmSwift

enum Weather: String, PersistableEnum {
    case sun = "sun"
    case rain = "rain"
    case cloud = "cloud"
    case thunder = "thunder"
    case snow = "snow"
}

enum Place: String, PersistableEnum {
    case home = "home"
    case school = "school"
    case company = "company"
    case car = "car"
    case place = "place"
}
