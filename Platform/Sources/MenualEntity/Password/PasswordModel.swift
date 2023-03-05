//
//  ProfilePasswordModel.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import Foundation
import RealmSwift

// MARK: - Realm에 저장하기위한 Class
public class PasswordModelRealm: Object, Codable {
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
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case password
        case isEnabled
    }
    
    public override init() {
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(ObjectId.self, forKey: ._id)
        password = try container.decode(Int.self, forKey: .password)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id.stringValue, forKey: ._id)
        try container.encode(password, forKey: .password)
        try container.encode(isEnabled, forKey: .isEnabled)
    }
}
