//
//  Diary.swift
//  Menual
//
//  Created by 정진균 on 2022/04/09.
//

import Foundation
import RealmSwift
import IceCream

// MARK: - 앱에서 사용하는 DiaryModel
public struct DiaryModel {
    let title: String
    let weather: String // TODO: 날씨 타입 추가
    let location: String // TODO: 위치 타입 추가
    let description: String
    let image: String // TODO: 이미지 타입 추가
    
    // 각 Property를 넣어서 초기화
    init(title: String, weather: String, location: String, description: String, image: String) {
        self.title = title
        self.weather = weather
        self.location = location
        self.description = description
        self.image = image
    }
    
    // Realm 객체를 넣어서 초기화
    init(_ realm: DiaryModelRealm) {
        self.title = realm.title
        self.weather = realm.weather
        self.location = realm.location
        self.description = realm.desc
        self.image = realm.image
    }
}

// MARK: - Realm에 저장하기 위한 Class
class DiaryModelRealm: Object {
    // @objc dynamic var id: ObjectId
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var title = ""
    @objc dynamic var weather: String = ""
    @objc dynamic var location: String = ""
    @objc dynamic var desc: String = ""
    @objc dynamic var image: String = ""
    @objc dynamic var isDeleted = false
    
    // Return a list of indexed property names
    override static func indexedProperties() -> [String] {
        return ["title"]
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(title: String, weather: String, location: String, desc: String, image: String) {
        self.init()
        self.title = title
        self.weather = weather
        self.location = location
        self.desc = desc
        self.image = image
    }
    
    convenience init(_ diaryModel: DiaryModel) {
        self.init()
        self.title = diaryModel.title
        self.weather = diaryModel.weather
        self.location = diaryModel.location
        self.desc = diaryModel.description
        self.image = diaryModel.image
    }
}

extension DiaryModelRealm: CKRecordConvertible & CKRecordRecoverable {
}
