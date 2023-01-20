//
//  DiaryReplayModel.swift
//  Menual
//
//  Created by 정진균 on 2022/06/05.
//

import Foundation
import RealmSwift

// MARK: - Realm에 저장하기 위한 Class
public class DiaryReplyModelRealm: EmbeddedObject {
    @Persisted public var uuid: String = ""
    @Persisted public var replyNum: Int
    @Persisted public var diaryUuid: String
    @Persisted public var desc: String
    @Persisted public var createdAt: Date
    @Persisted public var isDeleted: Bool
    
    convenience public init(uuid: String, replyNum: Int, diaryUuid: String, desc: String, createdAt: Date, isDeleted: Bool) {
        self.init()
        self.uuid = uuid
        self.replyNum = replyNum
        self.diaryUuid = diaryUuid
        self.desc = desc
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
    
    public func updateReplyNum(replyNum: Int) {
        self.replyNum = replyNum + 1
    }
}
