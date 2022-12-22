//
//  Diary.swift
//  Menual
//
//  Created by 정진균 on 2022/04/09.
//

import Foundation
import RealmSwift

// MARK: - Realm에 저장하기 위한 Class
public class DiaryModelRealm: Object {
    // @objc dynamic var id: ObjectId
    @Persisted(primaryKey: true) var _id: ObjectId
    var uuid: String {
        get {
            return _id.stringValue
        }
    }
    @Persisted var pageNum: Int
    @Persisted var title = ""
    @Persisted var weather: WeatherModelRealm?
    @Persisted var place: PlaceModelRealm?
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
                return UIImage(contentsOfFile: imageURL.path)?.jpegData(compressionQuality: 0.8)
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
    @Persisted var lastMomentsDate: Date?
    @Persisted var isHide: Bool
    @Persisted var reminder: ReminderModelRealm?
    
    convenience init(pageNum: Int,
                     title: String,
                     weather: WeatherModelRealm?,
                     place: PlaceModelRealm?,
                     desc: String,
                     image: Bool,
                     readCount: Int = 0,
                     createdAt: Date,
                     replies: [DiaryReplyModelRealm] = [],
                     isDeleted: Bool = false,
                     lastMomentsDate: Date? = nil,
                     isHide: Bool = false,
                     reminder: ReminderModelRealm? = nil
    ) {
        self.init()
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
        self.lastMomentsDate = lastMomentsDate
        // self.replies.append(objectsIn: replies)
        self.isHide = isHide
        self.reminder = reminder
    }
    
    func updatePageNum(pageNum: Int) {
        self.pageNum = pageNum + 1
    }
}
