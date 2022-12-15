//
//  SearchModel.swift
//  Menual
//
//  Created by 정진균 on 2022/04/30.
//

import Foundation
import RealmSwift

// MARK: - Realm에 저장하기 위한 Class
class SearchModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    var uuid: String {
        get { _id.stringValue }
    }
    @Persisted var keyword: String = ""
    @Persisted var createdAt: Date = Date()
    @Persisted var isDeleted: Bool = false
    
    convenience init(keyword: String, createdAt: Date, isDeleted: Bool = false) {
        self.init()
        self.keyword = keyword
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
}
