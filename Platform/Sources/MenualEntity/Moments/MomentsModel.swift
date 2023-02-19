//
//  MomentsModel.swift
//  Menual
//
//  Created by 정진균 on 2022/12/13.
//

import Foundation
import RealmSwift

// MARK: - 메인에 추천하는 추천 Moments 모델
public class MomentsRealm: Object, Codable {
    @Persisted(primaryKey: true) public var _id: ObjectId
    @Persisted public var lastUpdatedDate: Date
    @Persisted public var onboardingClearDate: Date?
    @Persisted public var onboardingIsClear: Bool
    @Persisted public var items: List<MomentsItemRealm>
    public var itemsArr: [MomentsItemRealm] {
        get {
            return items.map { $0 }
        }
        set {
            items.removeAll()
            items.append(objectsIn: newValue)
        }
    }
    
    public convenience init(lastUpdatedDate: Date, onboardingClearDate: Date? = nil, onboardingIsClear: Bool = false, items: [MomentsItemRealm]) {
        self.init()
        self.lastUpdatedDate = lastUpdatedDate
        self.itemsArr = items
    }
    
    public override init() {
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case lastUpdatedDate
        case onboardingClearDate
        case onboardingIsClear
        case items
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(ObjectId.self, forKey: ._id)
        lastUpdatedDate = try container.decode(Date.self, forKey: .lastUpdatedDate)
        onboardingClearDate = try container.decodeIfPresent(Date.self, forKey: .onboardingClearDate)
        onboardingIsClear = try container.decode(Bool.self, forKey: .onboardingIsClear)
        items = try container.decode(List<MomentsItemRealm>.self, forKey: .items)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(lastUpdatedDate, forKey: .lastUpdatedDate)
        try container.encodeIfPresent(onboardingClearDate, forKey: .onboardingClearDate)
        try container.encode(onboardingIsClear, forKey: .onboardingIsClear)
        try container.encode(items, forKey: .items)
    }
}

// MARK: - Moments 안에 세세하게 사용되는 아이템
public class MomentsItemRealm: EmbeddedObject, Codable {
    @Persisted public var order: Int
    @Persisted public var title: String
    @Persisted public var uuid: String
    @Persisted public var icon: String
    @Persisted public var diaryUUID: String
    @Persisted public var userChecked: Bool
    @Persisted public var createdAt: Date
    
    public convenience init(order: Int, title: String, uuid: String, icon: String, diaryUUID: String, userChecked: Bool, createdAt: Date) {
        self.init()
        self.order = order
        self.title = title
        self.uuid = uuid
        self.icon = icon
        self.diaryUUID = diaryUUID
        self.userChecked = userChecked
        self.createdAt = createdAt
    }
    
    public override init() {
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case order
        case title
        case uuid
        case icon
        case diaryUUID
        case userChecked
        case createdAt
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        order = try container.decode(Int.self, forKey: .order)
        title = try container.decode(String.self, forKey: .title)
        uuid = try container.decode(String.self, forKey: .uuid)
        icon = try container.decode(String.self, forKey: .icon)
        diaryUUID = try container.decode(String.self, forKey: .diaryUUID)
        userChecked = try container.decode(Bool.self, forKey: .userChecked)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(order, forKey: .order)
        try container.encode(title, forKey: .title)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(icon, forKey: .icon)
        try container.encode(diaryUUID, forKey: .diaryUUID)
        try container.encode(userChecked, forKey: .userChecked)
        try container.encode(createdAt, forKey: .createdAt)
    }
}
