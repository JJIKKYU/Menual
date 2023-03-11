//
//  ReminderModel.swift
//  Menual
//
//  Created by 정진균 on 2022/11/16.
//

import Foundation
import RealmSwift

public class ReminderModelRealm: EmbeddedObject, Codable {
    @Persisted public var uuid: String
    @Persisted public var requestDate: Date
    @Persisted public var createdAt: Date
    @Persisted public var isEnabled: Bool

    convenience public init(uuid: String, requestDate: Date, createdAt: Date, isEnabled: Bool) {
        self.init()
        self.uuid = uuid
        self.requestDate = requestDate
        self.createdAt = createdAt
        self.isEnabled = isEnabled
    }
    enum CodingKeys: String,CodingKey {
        case uuid
        case requestDate
        case createdAt
        case isEnabled
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(String.self, forKey: .uuid)
        requestDate = try container.decode(Date.self, forKey: .requestDate)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(requestDate, forKey: .requestDate)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isEnabled, forKey: .isEnabled)
    }
}
