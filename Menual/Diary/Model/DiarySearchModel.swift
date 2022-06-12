//
//  DiarySearchModel.swift
//  Menual
//
//  Created by 정진균 on 2022/06/12.
//

import Foundation
import RealmSwift

// MARK: - 앱에서 사용하는 DiarySearchModel
public struct DiarySearchModel {
    let uuid: String
    let diaryUuid: String
    let diary: DiaryModel?
    let createdAt: Date
    let isDeleted: Bool
    
    init(uuid: String, diaryUuid: String, diary: DiaryModel?, createdAt: Date, isDeleted: Bool) {
        self.uuid = uuid
        self.diaryUuid = diaryUuid
        self.diary = diary
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
    
    init(_ realm: DiarySearchModelRealm) {
        self.uuid = realm.uuid
        self.diaryUuid = realm.diaryUuid
        if let realmDiary = realm.diary {
            self.diary = DiaryModel(realmDiary)
        } else {
            self.diary = nil
        }
        self.createdAt = realm.createdAt
        self.isDeleted = realm.isDeleted
    }
}

// MARK: - Realm에 저장하기 위한 Class
class DiarySearchModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid: String
    @Persisted var diaryUuid: String
    @Persisted var diary: DiaryModelRealm?
    @Persisted var createdAt: Date
    @Persisted var isDeleted: Bool
    
    convenience init(uuid: String, diaryUuid: String, diary: DiaryModelRealm?, createdAt: Date, isDeleted: Bool) {
        self.init()
        self.uuid = uuid
        self.diaryUuid = diaryUuid
        self.diary = diary
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
    
    convenience init(_ diarySearchModel: DiarySearchModel) {
        self.init()
        self.uuid = diarySearchModel.uuid
        self.diaryUuid = diarySearchModel.diaryUuid
        if let diarySearchModelDiary = diarySearchModel.diary {
            self.diary = DiaryModelRealm(diarySearchModelDiary)
        } else {
            self.diary = nil
        }
        self.createdAt = diarySearchModel.createdAt
        self.isDeleted = diarySearchModel.isDeleted
    }
}
