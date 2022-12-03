//
//  Diary.swift
//  Menual
//
//  Created by 정진균 on 2022/04/09.
//

import Foundation
import RealmSwift

// MARK: - 앱에서 사용하는 TempSaveModel
public struct TempSaveModel {
    let uuid: String
    let title: String
    let description: String
    let image: Data?
    let originalImage: Data?
    let weather: Weather?
    let weatherDetailText: String?
    let place: Place?
    let placeDetilText: String?
    let createdAt: Date
    let isDeleted: Bool
    
    init(uuid: String, diaryModel: DiaryModel, createAt: Date, isDeleted: Bool) {
        self.uuid = uuid
        self.title = diaryModel.title
        self.description = diaryModel.description
        self.image = diaryModel.image
        self.originalImage = diaryModel.originalImage
        self.weather = diaryModel.weather?.weather
        self.weatherDetailText = diaryModel.weather?.detailText
        self.place = diaryModel.place?.place
        self.placeDetilText = diaryModel.place?.detailText
        self.createdAt = createAt
        self.isDeleted = isDeleted
    }
    
    init(_ realm: TempSaveModelRealm) {
        self.uuid = realm.uuid
        self.title = realm.title
        self.description = realm.desc
        self.weather = realm.weather
        self.weatherDetailText = realm.weatherDetailText
        self.place = realm.place
        self.placeDetilText = realm.placeDetailText
        self.createdAt = realm.createdAt
        self.isDeleted = realm.isDeleted
        
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
    }
}

// MARK: - Realm에 저장하기 위한 Class
public class TempSaveModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid: String = ""
    @Persisted var title: String = ""
    @Persisted var desc: String = ""
    @Persisted var image: Bool
    @Persisted var weather: Weather?
    @Persisted var weatherDetailText: String?
    @Persisted var place: Place?
    @Persisted var placeDetailText: String?
    @Persisted var createdAt: Date
    @Persisted var isDeleted: Bool
    
    convenience init(uuid: String, diaryModel: DiaryModel, createdAt: Date, isDeleted: Bool) {
        self.init()
        self.uuid = uuid
        self.title = diaryModel.title
        self.desc = diaryModel.description
        self.image = diaryModel.image != nil ? true : false
        self.weather = diaryModel.weather?.weather
        self.weatherDetailText = diaryModel.weather?.detailText
        self.place = diaryModel.place?.place
        self.placeDetailText = diaryModel.place?.detailText
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
    
    convenience init(_ tempSaveModel: TempSaveModel) {
        self.init()
        self.uuid = tempSaveModel.uuid
        self.title = tempSaveModel.title
        self.desc = tempSaveModel.description
        self.image = tempSaveModel.image != nil ? true : false
        self.weather = tempSaveModel.weather
        self.weatherDetailText = tempSaveModel.weatherDetailText
        self.place = tempSaveModel.place
        self.placeDetailText = tempSaveModel.placeDetilText
        
        self.createdAt = tempSaveModel.createdAt
        self.isDeleted = tempSaveModel.isDeleted
    }
}
