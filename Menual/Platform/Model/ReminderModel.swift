//
//  ReminderModel.swift
//  Menual
//
//  Created by 정진균 on 2022/11/16.
//

import Foundation
import RealmSwift

public class ReminderModelRealm: EmbeddedObject {
    @Persisted var uuid: String
    @Persisted var requestDate: Date
    @Persisted var createdAt: Date
    @Persisted var isEnabled: Bool
    
    convenience init(uuid: String, requestDate: Date, createdAt: Date, isEnabled: Bool) {
        self.init()
        self.uuid = uuid
        self.requestDate = requestDate
        self.createdAt = createdAt
        self.isEnabled = isEnabled
    }
}
