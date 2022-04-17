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
    let uuid: String
    let title: String
    let weather: Weather?
    let location: Place? // TODO: 위치 타입 추가
    let description: String
    let image: UIImage? // TODO: 이미지 타입 추가
    let readCount: Int
    let createdAt: Date
    // let createdAt: Date
    
    // 각 Property를 넣어서 초기화
    init(uuid: String, title: String, weather: Weather?, location: Place?, description: String, image: UIImage?, readCount: Int, createdAt: Date) {
        self.uuid = uuid
        self.title = title
        self.weather = weather
        self.location = location
        self.description = description
        self.image = image
        self.readCount = readCount
        self.createdAt = createdAt
    }
    
    // Realm 객체를 넣어서 초기화
    init(_ realm: DiaryModelRealm) {
        self.uuid = realm.uuid
        self.title = realm.title
        self.weather = realm.weather
        self.location = realm.location
        self.description = realm.desc
        // self.image = realm.image
        
        // 1. 도큐먼트 폴더 경로가져오기
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let directoryPath = path.first {
        // 2. 이미지 URL 찾기
            let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(realm.uuid)
            // 3. UIImage로 불러오기
            self.image = UIImage(contentsOfFile: imageURL.path)
        } else {
            self.image = nil
        }
        
        self.readCount = realm.readCount
        self.createdAt = realm.createdAt
    }
}

// MARK: - Realm에 저장하기 위한 Class
class DiaryModelRealm: Object {
    // @objc dynamic var id: ObjectId
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid = ""
    @Persisted var title = ""
    @Persisted var weather: Weather?
    @Persisted var location: Place?
    @Persisted var desc: String = ""
    @Persisted var image: Bool = false
    @Persisted var readCount: Int
    @Persisted var createdAt = Date()
    // @Persisted var createdAt: Date = Date()
    @Persisted var isDeleted = false
    
    convenience init(uuid: String, title: String, weather: Weather?, location: Place?, desc: String, image: Bool, readCount: Int) {
        self.init()
        self.uuid = uuid
        self.title = title
        self.weather = weather
        self.location = location
        self.desc = desc
        self.image = image
        self.readCount = readCount
        // self.createdAt = createdAt
        self.isDeleted = false
    }
    
    convenience init(_ diaryModel: DiaryModel) {
        self.init()
        self.uuid = diaryModel.uuid
        self.title = diaryModel.title
        self.weather = diaryModel.weather
        self.location = diaryModel.location
        self.desc = diaryModel.description
        
        // 이미지 유무만 저장
        self.image = false
        if diaryModel.image != nil {
            self.image = true
        }
        
        // self.createdAt = diaryModel.createdAt
        self.readCount = readCount
        self.isDeleted = false
    }
}
