//
//  DiarySearchModel.swift
//  Menual
//
//  Created by 정진균 on 2022/06/12.
//

import Foundation
import RealmSwift

// MARK: - Realm에 저장하기 위한 Class
class DiarySearchModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    var uuid: String {
        get { _id.stringValue }
    }
    @Persisted var diaryUuid: String
    @Persisted var diary: DiaryModelRealm?
    @Persisted var createdAt: Date
    @Persisted var isDeleted: Bool
    
    convenience init(diaryUuid: String, diary: DiaryModelRealm?, createdAt: Date, isDeleted: Bool) {
        self.init()
        self.diaryUuid = diaryUuid
        self.diary = diary
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
}
