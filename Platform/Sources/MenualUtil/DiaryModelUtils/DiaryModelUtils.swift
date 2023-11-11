//
//  DiaryModelUtils.swift
//
//
//  Created by 정진균 on 11/11/23.
//

import Foundation
import UIKit

public class DiaryModelUtils {
    public static func getThumbImage(
        uuid: String,
        thumbIndex: Int,
        completion: @escaping (Data?) -> ()
    ) {
        guard let directoryPath: String = getDiaryFolderPath(uuid: uuid) else {
            completion(nil)
            return
        }

        let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
        dispatchQueue.async {
            let thumbImageURL: URL = URL(filePath: directoryPath).appendingPathComponent("images_\(thumbIndex).jpg")

            guard let thumbImage: UIImage = UIImage(contentsOfFile: thumbImageURL.path) else {
                completion(nil)
                return
            }


            let thumbImageData: Data? = thumbImage
                .jpegData(compressionQuality: 0.5)

            DispatchQueue.main.async {
                completion(thumbImageData)
            }
        }
    }

    public static func getImages(
        uuid: String,
        imageCount: Int,
        completion: @escaping ([Data]) -> ()
    ) {
        guard let directoryPath: String = getDiaryFolderPath(uuid: uuid) else {
            completion([])
            return
        }
        var imagesData: [Data] = []
        let imageCount: Int = imageCount

        let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
        dispatchQueue.async {
            for index in 0..<imageCount {
                let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent("images_\(index).jpg")

                if let imageData = UIImage(contentsOfFile: imageURL.path)?.jpegData(compressionQuality: 0.9) {
                    imagesData.append(imageData)
                }
            }

            DispatchQueue.main.async {
                completion(imagesData)
            }
        }

    }

    public static func getDiaryFolderPath(uuid: String) -> String? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let folderURL: URL = documentDirectory.appendingPathComponent(uuid)

        return folderURL.path
    }
}
