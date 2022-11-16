//
//  ReminderModel.swift
//  Menual
//
//  Created by 정진균 on 2022/11/16.
//

import Foundation
import RealmSwift

// MARK: - 앱에서 사용하는 ReminderModel
public struct ReminderModel {
    let uuid: String
    let diaryUUID: String
    let requestDate: Date
    let requestUUID: String
    let createdAt: Date
    let isEnabled: Bool

    init(uuid: String, diaryUUID: String, requestDate: Date, requestUUID: String, createdAt: Date, isEnabled: Bool) {
        self.uuid = uuid
        self.diaryUUID = diaryUUID
        self.requestDate = requestDate
        self.requestUUID = requestUUID
        self.createdAt = createdAt
        self.isEnabled = isEnabled
    }
    
    init(_ realm: ReminderModelRealm) {
        self.uuid = realm.uuid
        self.diaryUUID = realm.uuid
        self.requestDate = realm.requestDate
        self.requestUUID = realm.requestUUID
        self.createdAt = realm.createdAt
        self.isEnabled = realm.isEnabled
    }
}

// MARK: - Realm에 저장하기 위한 Class
public class ReminderModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid: String
    @Persisted var diaryUUID: String
    @Persisted var requestDate: Date
    @Persisted var requestUUID: String
    @Persisted var createdAt: Date
    @Persisted var isEnabled: Bool
    
    convenience init(uuid: String, diaryUUID: String, requestDate: Date, reqeustUUID: String, createdAt: Date, isEnabled: Bool) {
        self.init()
        self.uuid = uuid
        self.diaryUUID = diaryUUID
        self.requestDate = requestDate
        self.requestUUID = reqeustUUID
        self.createdAt = createdAt
        self.isEnabled = isEnabled
    }
    
    convenience init(_ model: ReminderModel) {
        self.init()
        self.uuid = model.uuid
        self.diaryUUID = model.diaryUUID
        self.requestDate = model.requestDate
        self.requestUUID = model.requestUUID
        self.createdAt = model.createdAt
        self.isEnabled = model.isEnabled
    }
}
