//
//  Diary.swift
//  Menual
//
//  Created by 정진균 on 2022/04/09.
//

import Foundation
// import MenualUtil
import Photos
import RealmSwift
import UIKit

// MARK: - Realm에 저장하기 위한 Class
public class DiaryModelRealm: Object, Codable {
    // @objc dynamic var id: ObjectId
    @Persisted(primaryKey: true) public var _id: ObjectId
    public var uuid: String {
        get {
            return _id.stringValue
        }
    }
    @Persisted public var version: Double
    @Persisted public var pageNum: Int
    @Persisted public var title = ""
    @Persisted public var weather: WeatherModelRealm?
    @Persisted public var place: PlaceModelRealm?
    @Persisted public var desc: String = ""
    // 이미지가 1개라도 있을 경우 true/false 반환
    @Persisted public var image: Bool
    @Persisted public var thumbImageIndex: Int
    @Persisted public var imageCount: Int
    public var images: [Data] {
        get {
            if image == false { return [] }

            guard let directoryPath: String = getDiaryFolderPath() else { return [] }

            var imagesData: [Data] = []
            for index in 0..<imageCount {
                // 2. 이미지 URL 찾기
                let imageURL: URL = .init(fileURLWithPath: directoryPath)
                    .appendingPathComponent("images_" + "\(index).jpg")

                // 3. UIImage로 불러오고 Data로 Return
                let imageData: Data = UIImage(contentsOfFile: imageURL.path)?
                    .jpegData(compressionQuality: 0.4) ?? Data()

                imagesData.append(imageData)
            }

            return imagesData
        }
    }

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

    public convenience init(
        version: Double = 0.1,
        pageNum: Int,
        title: String,
        weather: WeatherModelRealm?,
        place: PlaceModelRealm?,
        desc: String,
        image: Bool,
        imageCount: Int,
        thumbImageIndex: Int,
        readCount: Int = 0,
        createdAt: Date,
        replies: [DiaryReplyModelRealm] = [],
        isDeleted: Bool = false,
        lastMomentsDate: Date? = nil,
        isHide: Bool = false,
        reminder: ReminderModelRealm? = nil
    ) {
        self.init()
        self.version = version
        self.pageNum = pageNum
        self.title = title
        self.weather = weather
        self.place = place
        self.desc = desc
        self.image = image
        self.imageCount = imageCount
        self.thumbImageIndex = thumbImageIndex
        self.readCount = readCount
        self.createdAt = createdAt
        self.isDeleted = isDeleted
        self.repliesArr = replies
        self.lastMomentsDate = lastMomentsDate
        // self.replies.append(objectsIn: replies)
        self.isHide = isHide
        self.reminder = reminder
    }

    public convenience init(backupDic: [[String: Any]]) {
        self.init()
    }

    public func updatePageNum(pageNum: Int) {
        self.pageNum = pageNum + 1
    }

    enum CodingKeys: String,CodingKey {
        case version
        case _id
        case pageNum
        case title
        case weather
        case place
        case desc
        case image
        case imageCount
        case thumbImageIndex
        case readCount
        case createdAt
        case isDeleted
        case replies
        case lastMomentsDate
        case isHide
        case reminder
    }

    public override init() {
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        _id = try container.decode(ObjectId.self, forKey: ._id)
        version = try container.decodeIfPresent(Double.self, forKey: .version) ?? 0.1
        pageNum = try container.decode(Int.self, forKey: .pageNum)
        title = try container.decode(String.self, forKey: .title)
        weather = try container.decode(WeatherModelRealm?.self, forKey: .weather)
        place = try container.decode(PlaceModelRealm?.self, forKey: .place)
        desc = try container.decode(String.self, forKey: .desc)
        image = try container.decode(Bool.self, forKey: .image)
        imageCount = try container.decodeIfPresent(Int.self, forKey: .imageCount) ?? 1
        thumbImageIndex = try container.decodeIfPresent(Int.self, forKey: .thumbImageIndex) ?? 0
        readCount = try container.decode(Int.self, forKey: .readCount)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isDeleted = try container.decode(Bool.self, forKey: .isDeleted)
        replies = try container.decode(List<DiaryReplyModelRealm>.self, forKey: .replies)
        lastMomentsDate = try container.decode(Date?.self, forKey: .lastMomentsDate)
        isHide = try container.decode(Bool.self, forKey: .isHide)
        reminder = try container.decode(ReminderModelRealm?.self, forKey: .reminder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encodeIfPresent(version, forKey: .version)
        try container.encode(pageNum, forKey: .pageNum)
        try container.encode(title, forKey: .title)
        try container.encode(weather, forKey: .weather)
        try container.encode(place, forKey: .place)
        try container.encode(desc, forKey: .desc)
        try container.encode(image, forKey: .image)
        try container.encodeIfPresent(imageCount, forKey: .imageCount)
        try container.encodeIfPresent(thumbImageIndex, forKey: .thumbImageIndex)
        try container.encode(readCount, forKey: .readCount)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isDeleted, forKey: .isDeleted)
        try container.encode(replies, forKey: .replies)
        try container.encode(lastMomentsDate, forKey: .lastMomentsDate)
        try container.encode(isHide, forKey: .isHide)
        try container.encode(reminder, forKey: .reminder)
    }
}

// MARK: - Extension

extension DiaryModelRealm {
    private func getDiaryFolderPath() -> String? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let folderURL: URL = documentDirectory.appendingPathComponent(self.uuid)

        return folderURL.path
    }
}
