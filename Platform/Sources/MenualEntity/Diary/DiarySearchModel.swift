//
//  DiarySearchModel.swift
//  Menual
//
//  Created by 정진균 on 2022/06/12.
//

import Foundation
import RealmSwift

// MARK: - Realm에 저장하기 위한 Class
public class DiarySearchModelRealm: Object {
    @Persisted(primaryKey: true) public var _id: ObjectId
    public var uuid: String {
        get { _id.stringValue }
    }
    @Persisted public var diaryUuid: String
    @Persisted public var diary: DiaryModelRealm?
    @Persisted public var createdAt: Date
    @Persisted public var isDeleted: Bool
    
    convenience public init(diaryUuid: String, diary: DiaryModelRealm?, createdAt: Date, isDeleted: Bool) {
        self.init()
        self.diaryUuid = diaryUuid
        self.diary = diary
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
}
