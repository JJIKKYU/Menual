//
//  MomentsModel.swift
//  Menual
//
//  Created by 정진균 on 2022/12/13.
//

import Foundation
import RealmSwift

// MARK: - 메인에 추천하는 추천 Moments 모델
public class MomentsModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var diaryUUID: String
    @Persisted var userChecked: Bool
    @Persisted var lastUpdatedDate: Date
}
