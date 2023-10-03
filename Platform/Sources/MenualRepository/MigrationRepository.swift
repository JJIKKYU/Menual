//
//  MigrationRepository.swift
//
//
//  Created by 정진균 on 10/3/23.
//

import Foundation
import MenualUtil

// MARK: - MigrationRepository

public protocol MigrationRepository: AnyObject {
    // 이미지 저장 Path를 변환하는 함수
    func reorganizeFilesInDocumentDirectory(completion: @escaping (Bool) -> Void)
}

// MARK: - MigrationRepositoryImp

public final class MigrationRepositoryImp: MigrationRepository {
    public init() {

    }

    public func reorganizeFilesInDocumentDirectory(completion: @escaping (Bool) -> Void) {
        let fileManager: FileManager = .default
        guard let documentDirectory: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(false)
            return
        }

        do {
            let fileURLs: [URL] = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)

            for fileURL in fileURLs {
                let fileName: String = fileURL.lastPathComponent

                // {UUID}_images_{index} 로 되어 있으니 '_'를 기준으로 분리
                let components: [String] = fileName.components(separatedBy: "_")

                // 총 3개로 분리되지 않았다면 마이그레이션 하고자 하는 타겟이 아님
                if components.count != 3 { continue }

                // 첫번째 comp는 UUID
                guard let uuid: String = components[safe: 0] else {
                    continue
                }

                // 앞서 획득한 UUID로 폴더 생성
                let folderName: String = "\(uuid)/"
                let destinationFolderURL: URL = documentDirectory.appendingPathComponent(folderName)

                // 폴더가 만약 없다면 생성
                if !fileManager.fileExists(atPath: destinationFolderURL.path) {
                    try fileManager.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)
                }

                let trimmedFileName: String = String(fileName.suffix(from: "\(uuid)_".endIndex))
                let destinationFileURL: URL = destinationFolderURL.appendingPathComponent(trimmedFileName)

                try fileManager.moveItem(at: fileURL, to: destinationFileURL)

                print("Moved file from \(fileURL.path) to \(destinationFileURL.path)")
            }

            completion(true)
        } catch {
            completion(false)
            print("Error reorganizing files: \(error.localizedDescription)")
        }
    }
}
