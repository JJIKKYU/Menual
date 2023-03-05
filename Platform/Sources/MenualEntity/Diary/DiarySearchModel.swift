//
//  DiarySearchModel.swift
//  Menual
//
//  Created by 정진균 on 2022/06/12.
//

import Foundation
import RealmSwift

// MARK: - Realm에 저장하기 위한 Class
public class DiarySearchModelRealm: Object, Codable {
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
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case diaryUuid
        case diary
        case createdAt
        case isDeleted
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(ObjectId.self, forKey: ._id)
        diaryUuid = try container.decode(String.self, forKey: .diaryUuid)
        diary = try container.decodeIfPresent(DiaryModelRealm.self, forKey: .diary)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isDeleted = try container.decode(Bool.self, forKey: .isDeleted)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(diaryUuid, forKey: .diaryUuid)
        try container.encodeIfPresent(diary, forKey: .diary)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isDeleted, forKey: .isDeleted)
    }
}
