//
//  Diary.swift
//  Menual
//
//  Created by 정진균 on 2022/04/09.
//

import Foundation
import RealmSwift
import UIKit

// MARK: - Realm에 저장하기 위한 Class
public class TempSaveModelRealm: Object {
    @Persisted(primaryKey: true) public var _id: ObjectId
    @Persisted public var uuid: String
    @Persisted public var title: String = ""
    @Persisted public var desc: String = ""
    @Persisted public var image: Bool
    public var originalImage: Data? {
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
    public var cropImage: Data? {
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
                return UIImage(contentsOfFile: imageURL.path)?.jpegData(compressionQuality: 0.8)
            }
            return nil
        }
    }
    public var thumbImage: Data? {
        get {
            if image == false { return nil }
            // 1. 도큐먼트 폴더 경로가져오기
            let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
            let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

            if let directoryPath = path.first {
            // 2. 이미지 URL 찾기
                let thumbImageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(uuid + "Thumb")
                // 3. UIImage로 불러오고 Data로 Return
                return UIImage(contentsOfFile: thumbImageURL.path)?.jpegData(compressionQuality: 0.9)
            }
            return nil
        }
    }
    @Persisted public var weather: Weather?
    @Persisted public var weatherDetailText: String?
    @Persisted public var place: Place?
    @Persisted public var placeDetailText: String?
    @Persisted public var createdAt: Date
    @Persisted public var isDeleted: Bool
    
    convenience public init(uuid: String, diaryModel: DiaryModelRealm, createdAt: Date, isDeleted: Bool) {
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
