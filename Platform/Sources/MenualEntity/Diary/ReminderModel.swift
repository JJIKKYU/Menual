//
//  ReminderModel.swift
//  Menual
//
//  Created by 정진균 on 2022/11/16.
//

import Foundation
import RealmSwift

public class ReminderModelRealm: EmbeddedObject {
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
}
