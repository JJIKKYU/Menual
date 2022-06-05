//
//  DiaryReplayModel.swift
//  Menual
//
//  Created by 정진균 on 2022/06/05.
//

import Foundation
import RealmSwift

// MARK: - 앱에서 사용하는 DiaryReply
public struct DiaryReplyModel {
    let uuid: String
    let replyNum: Int
    let diaryUuid: String
    let desc: String
    let createdAt: Date
    let isDeleted: Bool
    
    init(uuid: String, replyNum: Int, diaryUuid: String, desc: String, createdAt: Date, isDeleted: Bool) {
        self.uuid = uuid
        self.replyNum = replyNum
        self.diaryUuid = diaryUuid
        self.desc = desc
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
    
    init(_ realm: DiaryReplyModelRealm) {
        self.uuid = realm.uuid
        self.replyNum = realm.replyNum
        self.diaryUuid = realm.diaryUuid
        self.desc = realm.desc
        self.createdAt = realm.createdAt
        self.isDeleted = realm.isDeleted
    }
}

// MARK: - Realm에 저장하기 위한 Class
class DiaryReplyModelRealm: EmbeddedObject {
//    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid: String = ""
    @Persisted var replyNum: Int
    @Persisted var diaryUuid: String
    @Persisted var desc: String
    @Persisted var createdAt: Date
    @Persisted var isDeleted: Bool
    
    convenience init(uuid: String, replyNum: Int, diaryUuid: String, desc: String, createdAt: Date, isDeleted: Bool) {
        self.init()
        self.uuid = uuid
        self.replyNum = replyNum
        self.diaryUuid = diaryUuid
        self.desc = desc
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
    
    convenience init(_ diaryReplyModel: DiaryReplyModel) {
        self.init()
        self.uuid = diaryReplyModel.uuid
        self.replyNum = diaryReplyModel.replyNum
        self.diaryUuid = diaryReplyModel.diaryUuid
        self.desc = diaryReplyModel.desc
        self.createdAt = diaryReplyModel.createdAt
        self.isDeleted = diaryReplyModel.isDeleted
    }
}
