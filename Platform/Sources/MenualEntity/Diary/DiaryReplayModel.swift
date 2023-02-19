//
//  DiaryReplayModel.swift
//  Menual
//
//  Created by 정진균 on 2022/06/05.
//

import Foundation
import RealmSwift

// MARK: - Realm에 저장하기 위한 Class
public class DiaryReplyModelRealm: EmbeddedObject, Codable {
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
    
    enum CodingKeys: String,CodingKey {
        case uuid
        case replyNum
        case diaryUuid
        case desc
        case createdAt
        case isDeleted
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(String.self, forKey: .uuid)
        replyNum = try container.decode(Int.self, forKey: .replyNum)
        diaryUuid = try container.decode(String.self, forKey: .diaryUuid)
        desc = try container.decode(String.self, forKey: .desc)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isDeleted = try container.decode(Bool.self, forKey: .isDeleted)
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
