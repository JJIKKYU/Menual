//
//  ProfilePasswordModel.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import Foundation
import RealmSwift

// MARK: - Realm에 저장하기위한 Class
public class PasswordModelRealm: Object {
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
}
