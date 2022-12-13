//
//  SearchModel.swift
//  Menual
//
//  Created by 정진균 on 2022/04/30.
//

import Foundation
import RealmSwift

// MARK: - Search
public struct SearchModel {
    let uuid: String
    let keyword: String
    let createdAt: Date
    let isDeleted: Bool
    
    init(uuid: String, keyword: String, createdAt: Date, isDeleted: Bool) {
        self.uuid = uuid
        self.keyword = keyword
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
    
    init(_ realm: SearchModelRealm) {
        self.uuid = realm.uuid
        self.keyword = realm.keyword
        self.createdAt = realm.createdAt
        self.isDeleted = realm.isDeleted
    }
}

// MARK: - Realm에 저장하기 위한 Class
class SearchModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid: String = ""
    @Persisted var keyword: String = ""
    @Persisted var createdAt: Date = Date()
    @Persisted var isDeleted: Bool = false
    
    convenience init(uuid: String, keyword: String, createdAt: Date, isDeleted: Bool = false) {
        self.init()
        self.uuid = uuid
        self.keyword = keyword
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
    
    convenience init(_ model: SearchModel) {
        self.init()
        self.uuid = model.uuid
        self.keyword = model.keyword
        self.createdAt = model.createdAt
        self.isDeleted = model.isDeleted
    }
}
