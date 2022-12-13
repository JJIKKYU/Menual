//
//  ReminderRequsetModel.swift
//  Menual
//
//  Created by 정진균 on 2022/11/26.
//

import Foundation

struct ReminderRequsetModel {
    // nil 일 경우 초기화할 때 사용
    var isEditing: Bool?
    var requestDateComponents: DateComponents?
    var requestDate: Date?
}
