//
//  Diary.swift
//  Menual
//
//  Created by 정진균 on 2022/04/09.
//

import Foundation
import RealmSwift

// MARK: - 앱에서 사용하는 DiaryModel
public struct DiaryModel {
    let title: String
    let weather: Weather?
    let location: Place? // TODO: 위치 타입 추가
    let description: String
    let image: String // TODO: 이미지 타입 추가
    // let createdAt: Date
    
    // 각 Property를 넣어서 초기화
    init(title: String, weather: Weather?, location: Place?, description: String, image: String) {
        self.title = title
        self.weather = weather
        self.location = location
        self.description = description
        self.image = image
        // self.createdAt = createdAt
    }
    
    // Realm 객체를 넣어서 초기화
    init(_ realm: DiaryModelRealm) {
        self.title = realm.title
        self.weather = realm.weather
        self.location = realm.location
        self.description = realm.desc
        self.image = realm.image
        // self.createdAt = realm.createdAt
    }
}

// MARK: - Realm에 저장하기 위한 Class
class DiaryModelRealm: Object {
    // @objc dynamic var id: ObjectId
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title = ""
    @Persisted var weather: Weather?
    @Persisted var location: Place?
    @Persisted var desc: String = ""
    @Persisted var image: String = ""
    // @Persisted var createdAt: Date = Date()
    @Persisted var isDeleted = false
    
    convenience init(title: String, weather: Weather?, location: Place?, desc: String, image: String) {
        self.init()
        self.title = title
        self.weather = weather
        self.location = location
        self.desc = desc
        self.image = image
        // self.createdAt = createdAt
        self.isDeleted = false
    }
    
    convenience init(_ diaryModel: DiaryModel) {
        self.init()
        self.title = diaryModel.title
        self.weather = diaryModel.weather
        self.location = diaryModel.location
        self.desc = diaryModel.description
        self.image = diaryModel.image
        // self.createdAt = diaryModel.createdAt
        self.isDeleted = false
    }
}
