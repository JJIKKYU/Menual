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
    var pageNum: Int
    let title: String
    let weather: WeatherModel?
    let place: PlaceModel? // TODO: 위치 타입 추가
    let description: String
    let image: UIImage? // TODO: 이미지 타입 추가
    let readCount: Int
    let createdAt: Date
    let replies: [DiaryReplyModel]
    // let createdAt: Date
    
    // 각 Property를 넣어서 초기화
    init(uuid: String, pageNum: Int, title: String, weather: WeatherModel?, place: PlaceModel?, description: String, image: UIImage?, readCount: Int, createdAt: Date, replies: [DiaryReplyModel]) {
        self.uuid = uuid
        self.pageNum = pageNum
        self.title = title
        self.weather = weather
        self.place = place
        self.description = description
        self.image = image
        self.readCount = readCount
        self.createdAt = createdAt
        self.replies = replies
    }
    
    // Realm 객체를 넣어서 초기화
    init(_ realm: DiaryModelRealm) {
        self.uuid = realm.uuid
        self.pageNum = realm.pageNum
        self.title = realm.title
        self.weather = WeatherModel(realm.weather ?? WeatherModelRealm())
        self.place = PlaceModel(realm.place ?? PlaceModelRealm())
        self.description = realm.desc
        
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
        
        let diaryReplyModelArr = Array(realm.replies).map { DiaryReplyModel($0) }
        self.replies = diaryReplyModelArr
    }
    
    mutating func updatePageNum(pageNum: Int) {
        self.pageNum = pageNum + 1
    }
}

// MARK: - Realm에 저장하기 위한 Class
class DiaryModelRealm: Object {
    // @objc dynamic var id: ObjectId
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid = ""
    @Persisted var pageNum: Int
    @Persisted var title = ""
    @Persisted var weather: WeatherModelRealm?
    @Persisted var place: PlaceModelRealm?
    @Persisted var desc: String = ""
    @Persisted var image: Bool = false
    @Persisted var readCount: Int
    @Persisted var createdAt = Date()
    // @Persisted var createdAt: Date = Date()
    @Persisted var isDeleted = false
    @Persisted var replies: List<DiaryReplyModelRealm>
    
    convenience init(uuid: String, pageNum: Int, title: String, weather: WeatherModelRealm?, place: PlaceModelRealm?, desc: String, image: Bool, readCount: Int, replies: [DiaryReplyModelRealm]) {
        self.init()
        self.uuid = uuid
        self.pageNum = pageNum
        self.title = title
        self.weather = weather
        self.place = place
        self.desc = desc
        self.image = image
        self.readCount = readCount
        // self.createdAt = createdAt
        self.isDeleted = false
        self.replies.append(objectsIn: replies)
    }
    
    convenience init(_ diaryModel: DiaryModel) {
        self.init()
        self.uuid = diaryModel.uuid
        self.pageNum = diaryModel.pageNum
        self.title = diaryModel.title
        self.weather = WeatherModelRealm(diaryModel.weather ?? WeatherModel(uuid: "", weather: nil, detailText: ""))
        self.place = PlaceModelRealm(diaryModel.place ?? PlaceModel(uuid: "", place: nil, detailText: ""))
        self.desc = diaryModel.description
        
        // 이미지 유무만 저장
        self.image = false
        if diaryModel.image != nil {
            self.image = true
        }
        
        // self.createdAt = diaryModel.createdAt
        self.readCount = readCount
        self.isDeleted = false

        let diaryReplyModelRealmArr = diaryModel.replies.map { DiaryReplyModelRealm($0) }
        self.replies.append(objectsIn: diaryReplyModelRealmArr)
    }
}
