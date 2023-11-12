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
public class TempSaveModelRealm: Object, Codable {
    @Persisted(primaryKey: true) public var _id: ObjectId
    @Persisted public var uuid: String
    @Persisted public var title: String = ""
    @Persisted public var desc: String = ""
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

    public var thumbImage: Data? {
        get {
            if image == false { return nil }

            guard let directoryPath: String = getDiaryFolderPath() else { return nil }

            let thumbImageURL: URL = URL(filePath: directoryPath).appendingPathComponent("images_\(thumbImageIndex)")

            return UIImage(contentsOfFile: thumbImageURL.path)? .jpegData(compressionQuality: 0.5)
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
        self.thumbImageIndex = diaryModel.thumbImageIndex
        self.imageCount = diaryModel.imageCount
        self.weather = diaryModel.weather?.weather
        self.weatherDetailText = diaryModel.weather?.detailText
        self.place = diaryModel.place?.place
        self.placeDetailText = diaryModel.place?.detailText
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
    
    public override init() {
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case uuid
        case title
        case desc
        case image
        case thumbImageIndex
        case imageCount
        case weather
        case weatherDetailText
        case place
        case placeDetailText
        case createdAt
        case isDeleted
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(ObjectId.self, forKey: ._id)
        uuid = try container.decode(String.self, forKey: .uuid)
        title = try container.decode(String.self, forKey: .title)
        desc = try container.decode(String.self, forKey: .desc)
        image = try container.decode(Bool.self, forKey: .image)
        thumbImageIndex = try container.decodeIfPresent(Int.self, forKey: .thumbImageIndex) ?? 0
        imageCount = try container.decodeIfPresent(Int.self, forKey: .imageCount) ?? 1
        // weather = try container.decodeIfPresent(Weather.self, forKey: .weather)
        if let weatherRawValue = try container.decodeIfPresent(String.self, forKey: .weather),
            let weather = Weather(rawValue: weatherRawValue) {
            self.weather = weather
        } else {
            self.weather = nil
        }

        weatherDetailText = try container.decodeIfPresent(String.self, forKey: .weatherDetailText)
        // place = try container.decodeIfPresent(Place.self, forKey: .place)
        if let placeRawValue = try container.decodeIfPresent(String.self, forKey: .place),
            let place = Place(rawValue: placeRawValue) {
            self.place = place
        } else {
            self.place = nil
        }
        placeDetailText = try container.decodeIfPresent(String.self, forKey: .placeDetailText)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isDeleted = try container.decode(Bool.self, forKey: .isDeleted)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(title, forKey: .title)
        try container.encode(desc, forKey: .desc)
        try container.encode(image, forKey: .image)
        try container.encodeIfPresent(thumbImageIndex, forKey: .thumbImageIndex)
        try container.encodeIfPresent(imageCount, forKey: .imageCount)
        try container.encodeIfPresent(weather?.rawValue ?? "", forKey: .weather)
        try container.encodeIfPresent(weatherDetailText, forKey: .weatherDetailText)
        try container.encodeIfPresent(place?.rawValue ?? "", forKey: .place)
        try container.encodeIfPresent(placeDetailText, forKey: .placeDetailText)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isDeleted, forKey: .isDeleted)
    }
}

// MARK: - Extension

extension TempSaveModelRealm {
    private func getDiaryFolderPath() -> String? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let folderURL: URL = documentDirectory.appendingPathComponent(self.uuid)

        return folderURL.path
    }
}
