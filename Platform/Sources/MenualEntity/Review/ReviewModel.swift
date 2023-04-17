//
//  ReviewModel.swift
//  
//
//  Created by 정진균 on 2023/04/16.
//

import Foundation
import RealmSwift

public class ReviewModelRealm: Object, Codable {
    @Persisted(primaryKey: true) public var _id: ObjectId
    @Persisted public var isRejected: Bool
    @Persisted public var isApproved: Bool
    @Persisted public var createdAt: Date
}
