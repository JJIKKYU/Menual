//
//  BackupRestoreRepository.swift
//  
//
//  Created by 정진균 on 2023/02/25.
//

import Foundation
import MenualEntity
import Realm
import RealmSwift

public protocol BackupRestoreRepository {
    func makeBackupData<T: Object & Codable>(of: T.Type) -> Data?
    func backUp() -> [Data]
    func makeRestoreData<T: Object & Codable>(of: T.Type, data: Data?) -> [T]?
    func restoreWithJsonSaveImageData(diaryModelRealm: [DiaryModelRealm], imageFiles: [ImageFile])
    func restoreWithJson(restoreFile: RestoreFile)
}

public final class BackupRestoreRepositoryImp: BackupRestoreRepository {
    public init() {
        
    }
    
    public func deleteImageFromDocumentDirectory(diaryUUID: String, completionHandler: @escaping (Bool) -> Void) {
        // 1. 이미지를 삭제할 경로를 설정해줘야함 - 도큐먼트 폴더,File 관련된건 Filemanager가 관리함(싱글톤 패턴)
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        
        // 2. 이미지 파일 이름 & 최종 경로 설정
        let imageURL = documentDirectory.appendingPathComponent(diaryUUID)
        let originalURL = documentDirectory.appendingPathComponent(diaryUUID + "Original")
        let thumblURL = documentDirectory.appendingPathComponent(diaryUUID + "Thumb")
        
        // 3. 이미지 삭제
        if FileManager.default.fileExists(atPath: imageURL.path) {
            // 4. 이미지가 존재한다면 기존 경로에 있는 이미지 삭제
            do {
                try FileManager.default.removeItem(at: imageURL)
                print("DiaryWriting :: DiaryRepository :: 이미지 삭제 완료 -> Crop")
            } catch {
                print("DiaryWriting :: DiaryRepository :: 이미지를 삭제하지 못했습니다.")
                completionHandler(false)
            }
        }
        
        if FileManager.default.fileExists(atPath: originalURL.path) {
            // 4. 이미지가 존재한다면 기존 경로에 있는 이미지 삭제
            do {
                try FileManager.default.removeItem(at: originalURL)
                print("DiaryWriting :: DiaryRepository :: 이미지 삭제 완료 -> Original")
            } catch {
                print("DiaryWriting :: DiaryRepository :: 이미지를 삭제하지 못했습니다.")
                completionHandler(false)
            }
        }
        
        if FileManager.default.fileExists(atPath: thumblURL.path) {
            // 4. 이미지가 존재한다면 기존 경로에 있는 이미지 삭제
            do {
                try FileManager.default.removeItem(at: thumblURL)
                print("DiaryWriting :: DiaryRepository :: 이미지 삭제 완료 -> Thumb")
            } catch {
                print("DiaryWriting :: DiaryRepository :: 이미지를 삭제하지 못했습니다.")
                completionHandler(false)
            }
        }
        
        
        completionHandler(true)
    }
    
    public func makeBackupData<T: Object & Codable>(of: T.Type) -> Data? {
        guard let realm = Realm.safeInit() else { return nil }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let array = realm
            .objects(T.self)
            .toArray(type: T.self)
        guard let data = try? encoder.encode(array) else { return nil }
        return data
    }
    
    public func backUp() -> [Data] {
        print("DiaryRepo :: backup!")
        var backupDataArr: [Data] = []
        var backupDataDic: [String: Data] = [:]
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let diaryData = makeBackupData(of: DiaryModelRealm.self)
        let momentsData = makeBackupData(of: MomentsRealm.self)
        let tempSaveData = makeBackupData(of: TempSaveModelRealm.self)
        let diarySearchData = makeBackupData(of: DiarySearchModelRealm.self)
        let passwordData = makeBackupData(of: PasswordModelRealm.self)
        let backupHistoryData = makeBackupData(of: BackupHistoryModelRealm.self)
        
        backupDataDic["diary"] = diaryData
        backupDataDic["moments"] = momentsData
        backupDataDic["tempSave"] = tempSaveData
        backupDataDic["diarySearch"] = diarySearchData
        backupDataDic["password"] = passwordData
        backupDataDic["backupHistory"] = backupHistoryData

        for data in backupDataDic {
            do {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileUrl = documentsDirectory.appendingPathComponent("\(data.key).json")
                try data.value.write(to: fileUrl, options: .atomic)
            } catch {
                print("Error saving JSON data: \(error)")
            }
        }
        
        print("DiaryRepo :: return!")
        return backupDataArr
    }
    
    public func makeRestoreData<T: Object & Codable>(of: T.Type, data: Data?) -> [T]? {
        // 데이터가 nil로 들어왔을 경우 restoreFile을 만들 필요가 없으므로 nil 리턴
        guard let data = data else { return nil }
        let decoder = JSONDecoder()
        
        guard let array = try? decoder.decode([T].self, from: data) else { return nil }
        return array
    }
    
    public func restoreWithJson(restoreFile: RestoreFile) {
        print("DiaryRepo :: restoreWithJson! restoreFile = \(restoreFile)")
        guard let realm = Realm.safeInit() else {
            return
        }
        let decoder = JSONDecoder()
        let fileManager = FileManager.default
        
        /// DiaryData

        if let diaryArray = makeRestoreData(of: DiaryModelRealm.self, data: restoreFile.diaryData) {
            restoreWithJsonSaveImageData(diaryModelRealm: diaryArray, imageFiles: restoreFile.imageDataArr)
            deleteDiaries()
            
            realm.safeWrite {
                realm.add(diaryArray)
            }
        }
        
        if let momentsArr = makeRestoreData(of: MomentsRealm.self, data: restoreFile.momentsData) {
            
        }

        if let passwordData = restoreFile.passwordData,
           let passwordDataArr = try? decoder.decode([PasswordModelRealm].self, from: passwordData) {
            
        }
        
        if let tempSaveData = restoreFile.tempSaveData,
           let tempSaveDataArr = try? decoder.decode([TempSaveModelRealm].self, from: tempSaveData) {
            
        }
        
        if let backupHistoryData = restoreFile.backupHistoryData,
           let backupHistoryDataArr = try? decoder.decode([BackupHistoryModelRealm].self, from: backupHistoryData) {
            
        }
    }
    
    public func deleteDiaries() {
        guard let realm = Realm.safeInit() else { return }
        let diaries = realm.objects(DiaryModelRealm.self)
        let searchData = realm.objects(DiarySearchModelRealm.self)
        var willDeleteImageData: [String] = []
        var willDeleteSearchData: [DiarySearchModelRealm] = []
        var willDeleteReminderData: [String] = []
        
        diaries.forEach { diary in

            realm.safeWrite {
                diary.isDeleted = true
            }

            if diary.image {
                willDeleteImageData.append(diary.uuid)
            }
            
            if let searchData = searchData.filter ({ $0.diaryUuid == diary.uuid }).first {
                willDeleteSearchData.append(searchData)
            }
            
            if let reminder = diary.reminder {
                willDeleteReminderData.append(reminder.uuid)
            }
        }

        realm.safeWrite {
            realm.delete(willDeleteSearchData)
            realm.add(diaries, update: .modified)
        }

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: willDeleteReminderData)
        
        willDeleteImageData.forEach { uuid in
            deleteImageFromDocumentDirectory(diaryUUID: uuid) { isDeleted in
                print("diaryRepo :: deleteDiaries! 이미지도 함께 삭제합니다.")
            }
        }
    }
    
    public func restoreWithJsonSaveImageData(diaryModelRealm: [DiaryModelRealm], imageFiles: [ImageFile]) {
        /// Key - 원래 ObjectId
        /// Value - 바뀐 ObjectId
        var objectIdSet: [String: String] = [:]

        // 신/구 ObjectId를 해쉬 형태로 세팅
        for diary in diaryModelRealm {
            guard let prevObjectId = diary.prevObjectId else { return }
            objectIdSet[prevObjectId] = diary.uuid
        }
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // 바뀐 ObjectId 이름으로 변경하여 이미지 세팅
        for imageFile in imageFiles {
            guard let newObjectId = objectIdSet[imageFile.fileName] else { return }
            let imageURL = documentDirectory.appendingPathComponent(newObjectId + imageFile.type.rawValue)
            try? imageFile.data.write(to: imageURL)
        }
    }
}
