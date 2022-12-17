//
//  Diary.swift
//  Menual
//
//  Created by 정진균 on 2022/04/09.
//

import Foundation
import RealmSwift

// MARK: - Realm에 저장하기 위한 Class
public class TempSaveModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid: String
    @Persisted var title: String = ""
    @Persisted var desc: String = ""
    @Persisted var image: Bool
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
    @Persisted var weather: Weather?
    @Persisted var weatherDetailText: String?
    @Persisted var place: Place?
    @Persisted var placeDetailText: String?
    @Persisted var createdAt: Date
    @Persisted var isDeleted: Bool
    
    convenience init(uuid: String, diaryModel: DiaryModelRealm, createdAt: Date, isDeleted: Bool) {
        self.init()
        self.uuid = uuid
        self.title = diaryModel.title
        self.desc = diaryModel.desc
        self.image = diaryModel.image
        self.weather = diaryModel.weather?.weather
        self.weatherDetailText = diaryModel.weather?.detailText
        self.place = diaryModel.place?.place
        self.placeDetailText = diaryModel.place?.detailText
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
}
