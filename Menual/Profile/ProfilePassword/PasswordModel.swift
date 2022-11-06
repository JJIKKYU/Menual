//
//  ProfilePasswordModel.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import Foundation
import RealmSwift

// MARK: - 앱에서 사용하는 Pass
public struct PasswordModel {
    let uuid: String
    let password: Int
    let isEnabled: Bool
    
    init(uuid: String, password: Int, isEnabled: Bool){
        self.uuid = uuid
        self.password = password
        self.isEnabled = isEnabled
    }
    
    init(_ realm: PasswordModelRealm) {
        self.uuid = realm.uuid
        self.password = realm.password
        self.isEnabled = realm.isEnabled
    }
}

// MARK: - Realm에 저장하기위한 Class
class PasswordModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid: String
    @Persisted var password: Int
    @Persisted var isEnabled: Bool
    
    convenience init(uuid: String, password: Int, isEnabled: Bool) {
        self.init()
        self.uuid = uuid
        self.password = password
        self.isEnabled = isEnabled
    }
    
    convenience init(_ model: PasswordModel) {
        self.init()
        self.uuid = model.uuid
        self.password = model.password
        self.isEnabled = model.isEnabled
    }
}
