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
    let id: ObjectId
    let uuid: String
    var pageNum: Int
    var title: String
    var weather: WeatherModel?
    var place: PlaceModel? // TODO: 위치 타입 추가
    var description: String
    var image: Data? // TODO: 이미지 타입 추가
    var originalImage: Data?
    var readCount: Int
    let createdAt: Date
    var replies: [DiaryReplyModel]
    var isDeleted: Bool
    var isHide: Bool
    // let createdAt: Date

    // 각 Property를 넣어서 초기화
    init(uuid: String, pageNum: Int, title: String, weather: WeatherModel?, place: PlaceModel?, description: String, image: Data?, originalImage: Data?, readCount: Int, createdAt: Date, replies: [DiaryReplyModel], isDeleted: Bool, isHide: Bool) {
        self.id = ObjectId()
        self.uuid = uuid
        self.pageNum = pageNum
        self.title = title
        self.weather = weather
        self.place = place
        self.description = description
        self.image = image
        self.originalImage = originalImage
        self.readCount = readCount
        self.createdAt = createdAt
        self.replies = replies
        self.isDeleted = isDeleted
        self.isHide = isHide
    }
    
    // Realm 객체를 넣어서 초기화
    init(_ realm: DiaryModelRealm) {
        self.id = realm._id
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
            let originalImageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(realm.uuid + "Original")
            // 3. UIImage로 불러오기
            self.image = UIImage(contentsOfFile: imageURL.path)?.jpegData(compressionQuality: 0.5)
            self.originalImage = UIImage(contentsOfFile: originalImageURL.path)?.jpegData(compressionQuality: 0.5)
        } else {
            self.image = nil
            self.originalImage = nil
        }
        
        
        self.readCount = realm.readCount
        self.createdAt = realm.createdAt
        
        let diaryReplyModelArr = Array(realm.replies).map { DiaryReplyModel($0) }
        self.replies = diaryReplyModelArr
        self.isDeleted = realm.isDeleted
        self.isHide = realm.isHide
    }
    
    mutating func updatePageNum(pageNum: Int) {
        self.pageNum = pageNum + 1
    }
    
    func getSectionName() -> String {
        print("getSectionName = \(createdAt)")
        let year: String = createdAt.toStringWithYYYY()
        let engMonth: String = createdAt.toStringWithMonthEngName()
        let yearEngMonth: String = "\(year)\(engMonth)"
        print("yearEngMonth = \(yearEngMonth)")
        return yearEngMonth
    }
}

// MARK: - Realm에 저장하기 위한 Class
public class DiaryModelRealm: Object {
    // @objc dynamic var id: ObjectId
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid = ""
    @Persisted var pageNum: Int
    @Persisted var title = ""
    @Persisted var weather: WeatherModelRealm?
    @Persisted var place: PlaceModelRealm?
    @Persisted var desc: String = ""
    @Persisted var image: Bool = false
    var originalImage: Data? {
        get {
            if image == false { return nil }
            // 1. 도큐먼트 폴더 경로가져오기
            let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
            let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

            if let directoryPath = path.first {
            // 2. 이미지 URL 찾기
                let originalImageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(uuid + "Original")
                // 3. UIImage로 불러오고 Data로 Return
                return UIImage(contentsOfFile: originalImageURL.path)?.jpegData(compressionQuality: 0.5)
            }
            return nil
        }
    }
    var cropImage: Data? {
        get {
            if image == false { return nil }
            // 1. 도큐먼트 폴더 경로가져오기
            let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
            let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
            
            if let directoryPath = path.first {
            // 2. 이미지 URL 찾기
                let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(uuid)
                // 3. UIImage로 불러오고 Data로 Return
                return UIImage(contentsOfFile: imageURL.path)?.jpegData(compressionQuality: 0.5)
            }
            return nil
        }
    }
    @Persisted var readCount: Int
    @Persisted var createdAt: Date
    @Persisted var isDeleted: Bool
    @Persisted var replies: List<DiaryReplyModelRealm>
    var repliesArr: [DiaryReplyModelRealm] {
        get {
            return replies.map { $0 }
        }
        set {
            replies.removeAll()
            replies.append(objectsIn: newValue)
        }
    }
    @Persisted var isHide: Bool
    
    convenience init(uuid: String, pageNum: Int, title: String, weather: WeatherModelRealm?, place: PlaceModelRealm?, desc: String, image: Bool, readCount: Int, createdAt: Date, replies: [DiaryReplyModelRealm], isDeleted: Bool, isHide: Bool) {
        self.init()
        self.uuid = uuid
        self.pageNum = pageNum
        self.title = title
        self.weather = weather
        self.place = place
        self.desc = desc
        self.image = image
        self.readCount = readCount
        self.createdAt = createdAt
        self.isDeleted = isDeleted
        self.repliesArr = replies
        // self.replies.append(objectsIn: replies)
        self.isHide = isHide
    }
    
    func updatePageNum(pageNum: Int) {
        self.pageNum = pageNum + 1
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
        
        self.createdAt = diaryModel.createdAt
        self.readCount = readCount
        self.isDeleted = diaryModel.isDeleted

        let diaryReplyModelRealmArr = diaryModel.replies.map { DiaryReplyModelRealm($0) }
        self.replies.append(objectsIn: diaryReplyModelRealmArr)
        self.isHide = isHide
    }
}
