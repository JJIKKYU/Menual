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
public class DiaryModelRealm: Object {
    // @objc dynamic var id: ObjectId
    @Persisted(primaryKey: true) public var _id: ObjectId
    public var uuid: String {
        get {
            return _id.stringValue
        }
    }
    @Persisted public var pageNum: Int
    @Persisted public var title = ""
    @Persisted public var weather: WeatherModelRealm?
    @Persisted public var place: PlaceModelRealm?
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
                return UIImage(contentsOfFile: originalImageURL.path)?.jpegData(compressionQuality: 0.9)
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
                return UIImage(contentsOfFile: imageURL.path)?.jpegData(compressionQuality: 1.0)
            }
            return nil
        }
    }
    @Persisted public var readCount: Int
    @Persisted public var createdAt: Date
    @Persisted public var isDeleted: Bool
    @Persisted public var replies: List<DiaryReplyModelRealm>
    public var repliesArr: [DiaryReplyModelRealm] {
        get {
            return replies.map { $0 }
        }
        set {
            replies.removeAll()
            replies.append(objectsIn: newValue)
        }
    }
    @Persisted public var lastMomentsDate: Date?
    @Persisted public var isHide: Bool
    @Persisted public var reminder: ReminderModelRealm?
    
    public convenience init(pageNum: Int,
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
    
    public func updatePageNum(pageNum: Int) {
        self.pageNum = pageNum + 1
    }
}