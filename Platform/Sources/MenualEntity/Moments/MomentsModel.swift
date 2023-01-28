//
//  MomentsModel.swift
//  Menual
//
//  Created by 정진균 on 2022/12/13.
//

import Foundation
import RealmSwift

// MARK: - 메인에 추천하는 추천 Moments 모델
public class MomentsRealm: Object {
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
}

// MARK: - Moments 안에 세세하게 사용되는 아이템
public class MomentsItemRealm: EmbeddedObject {
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
}
