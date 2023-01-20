//
//  ReminderRequsetModel.swift
//  Menual
//
//  Created by 정진균 on 2022/11/26.
//

import Foundation

public struct ReminderRequsetModel {
    // nil 일 경우 초기화할 때 사용
    public var isEditing: Bool?
    public var requestDateComponents: DateComponents?
    public var requestDate: Date?

    public init(isEditing: Bool? = nil, requestDateComponents: DateComponents? = nil, requestDate: Date? = nil) {
        self.isEditing = isEditing
        self.requestDateComponents = requestDateComponents
        self.requestDate = requestDate
    }
}
