//
//  File.swift
//  
//
//  Created by 정진균 on 2023/02/23.
//

import Foundation
import RealmSwift

public class BackupHistoryModelRealm: Object, Codable {
    @Persisted(primaryKey: true) public var _id: ObjectId
    public var uuid: String {
        get { _id.stringValue }
    }
    @Persisted public var pageCount: Int
    @Persisted public var diaryCount: Int
    @Persisted public var createdAt: Date
    
    convenience public init(pageCount: Int, diaryCount: Int, createdAt: Date) {
        self.init()
        self.pageCount = pageCount
        self.diaryCount = diaryCount
        self.createdAt = createdAt
    }
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case pageCount
        case diaryCount
        case createdAt
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(ObjectId.self, forKey: ._id)
        pageCount = try container.decode(Int.self, forKey: .pageCount)
        diaryCount = try container.decode(Int.self, forKey: .diaryCount)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(pageCount, forKey: .pageCount)
        try container.encode(diaryCount, forKey: .diaryCount)
        try container.encode(createdAt, forKey: .createdAt)
    }
}

