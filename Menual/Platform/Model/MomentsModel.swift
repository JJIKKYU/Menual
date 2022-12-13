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
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var lastUpdatedDate: Date
    @Persisted var items: List<MomentsItemRealm>
    var itemsArr: [MomentsItemRealm] {
        get {
            return items.map { $0 }
        }
        set {
            items.removeAll()
            items.append(objectsIn: newValue)
        }
    }
    
    convenience init(lastUpdatedDate: Date, items: [MomentsItemRealm]) {
        self.init()
        self.lastUpdatedDate = lastUpdatedDate
        self.itemsArr = items
    }
}

// MARK: - Moments 안에 세세하게 사용되는 아이템
public class MomentsItemRealm: EmbeddedObject {
    @Persisted var order: Int
    @Persisted var title: String
    @Persisted var uuid: String
    @Persisted var diaryUUID: String
    @Persisted var userChecked: Bool
    @Persisted var createdAt: Date
    
    convenience init(order: Int, title: String, uuid: String, diaryUUID: String, userChecked: Bool, createdAt: Date) {
        self.init()
        self.order = order
        self.title = title
        self.uuid = uuid
        self.diaryUUID = diaryUUID
        self.userChecked = userChecked
        self.createdAt = createdAt
    }
}
