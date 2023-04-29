//
//  ReviewModel.swift
//  
//
//  Created by 정진균 on 2023/04/16.
//

import Foundation
import RealmSwift

public class ReviewModelRealm: Object, Codable {
    @Persisted(primaryKey: true) public var _id: ObjectId
    @Persisted public var isRejected: Bool
    @Persisted public var isApproved: Bool
    @Persisted public var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case _id
        case isRejected
        case isApproved
        case createdAt
    }

    required public convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(ObjectId.self, forKey: ._id)
        self.isRejected = try container.decode(Bool.self, forKey: .isRejected)
        self.isApproved = try container.decode(Bool.self, forKey: .isApproved)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self._id, forKey: ._id)
        try container.encode(self.isRejected, forKey: .isRejected)
        try container.encode(self.isApproved, forKey: .isApproved)
        try container.encodeIfPresent(self.createdAt, forKey: .createdAt)
    }
}
