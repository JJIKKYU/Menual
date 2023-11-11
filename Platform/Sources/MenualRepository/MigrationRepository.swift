//
//  MigrationRepository.swift
//
//
//  Created by 정진균 on 10/3/23.
//

import Foundation
import MenualEntity
import MenualUtil
import RxRelay
import RxSwift

// MARK: - MigrationRepository

public protocol MigrationRepository: AnyObject {
    var migrationStateRelay: BehaviorRelay<MigrationState> { get }

    // 이미지 저장 Path를 변환하는 함수
    func reorganizeFilesInDocumentDirectory(completion: @escaping (Bool) -> Void)
    func migrationIfNeeded()
}

// MARK: - MigrationRepositoryImp

public final class MigrationRepositoryImp: MigrationRepository {
    public let migrationStateRelay: BehaviorRelay<MigrationState> = .init(value: .idle)

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

                let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                // 파일 혹은 폴더인지 확인
                guard let type = attributes[.type] as? FileAttributeType else {
                    completion(false)
                    return
                }

                // Realm 파일은 삭제하지않도록 예외처리
                if fileName.contains("realm") {
                    continue
                }

                // 폴더가 아닐 경우에 삭제가 필요한 파일은 삭제
                if type != .typeDirectory {
                    // Thumbnail은 사용하지 않으므로 삭제
                    if fileName.contains("Thumb") {
                        try fileManager.removeItem(atPath: fileURL.path)
                        continue
                    }

                    // Thumb는 삭제하고 Original이라는 텍스트가 없으면, CropImage이므로 삭제
                    if !fileName.contains("Original") {
                        try fileManager.removeItem(atPath: fileURL.path)
                        continue
                    }
                }

                let components: [String] = fileName.components(separatedBy: "Original")
                // 첫번째 comp는 UUID
                guard let uuid: String = components[safe: 0] else {
                    continue
                }

                if type == .typeDirectory {
                    print("MigrationRepo :: \(fileName)은 이미 마이그레이션 되었습니다.")
                    continue
                }

                // 이동하고자 하는 파일의 이름을 우선 변경
                let changeFileName: URL = documentDirectory
                    .deletingLastPathComponent()
                    .appendingPathComponent("images_0.jpg")
                if type != .typeDirectory {
                    try fileManager.moveItem(at: fileURL, to: changeFileName)
                }

                // 앞서 획득한 UUID로 폴더 생성
                let folderName: String = "\(uuid)/"
                let destinationFolderURL: URL = documentDirectory.appendingPathComponent(folderName)

                // 폴더가 만약 없다면 생성
                if !fileManager.fileExists(atPath: destinationFolderURL.path) {
                    try fileManager.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)
                }
                // 폴더가 있다면 삭제하고 만들기
                else {
                    try fileManager.removeItem(atPath: destinationFolderURL.path)
                    try fileManager.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)
                }

                let destinationFileURL: URL = destinationFolderURL.appendingPathComponent("images_0.jpg")

                try fileManager.moveItem(at: changeFileName, to: destinationFileURL)

                print("Moved file from \(fileURL.path) to \(destinationFileURL.path)")
            }

            completion(true)
        } catch {
            print("Error reorganizing files: \(error.localizedDescription)")
            completion(false)
        }
    }

    // 23.11.11 이미지 다중 선택 migration
    public func migrationIfNeeded() {
        print("MigrationRepo :: migrationIfNeeded!")
        let hasMigrated: Bool = UserDefaults.standard.bool(forKey: MigrationType.imageMultiSelect.rawValue)

        print("MigrationRepo :: hasMigrated = \(hasMigrated)")

//        if hasMigrated {
//            migrationStateRelay.accept(.notNeeded)
//            return
//        }

        migrationStateRelay.accept(.inProgress)
        reorganizeFilesInDocumentDirectory { [weak self] isCompleted in
            guard let self = self else { return }
            self.migrationStateRelay.accept(.completed)
            print("MigrationRepo :: 마이그레이션 완료!")
            UserDefaults.standard.setValue(true, forKey: MigrationType.imageMultiSelect.rawValue)
        }
    }
}
