//
//  Diary.swift
//  Menual
//
//  Created by 정진균 on 2022/04/09.
//

import Foundation
import RealmSwift

public struct DiaryModel {
    let title: String
    let weather: String // TODO: 날씨 타입 추가
    let location: String // TODO: 위치 타입 추가
    let description: String
    let image: String // TODO: 이미지 타입 추가
}

class DiaryModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name = ""
    @Persisted var breed: String?
    @Persisted var dateOfBirth = Date()
}
