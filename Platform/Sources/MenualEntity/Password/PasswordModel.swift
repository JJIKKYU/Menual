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
    @Persisted(primaryKey: true) public var _id: ObjectId
    var uuid: String {
        get { _id.stringValue }
    }
    @Persisted public var password: Int
    @Persisted public var isEnabled: Bool
    
    public convenience init(password: Int, isEnabled: Bool) {
        self.init()
        self.password = password
        self.isEnabled = isEnabled
    }
}
