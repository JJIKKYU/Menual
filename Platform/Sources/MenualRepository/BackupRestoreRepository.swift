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
    /// 백업 관련
    func backUp() -> [Data]///
    func makeBackupData<T: Object & Codable>(of: T.Type) -> Data?
    func addOrUpdateBackupHistory()
    
    /// 불러오기 관련
    func makeRestoreData<T: Object & Codable>(of: T.Type, data: Data?) -> [T]?
    func restoreWithJsonSaveImageData(diaryModelRealm: [DiaryModelRealm], imageFiles: [ImageFile])
    func restoreWithJson(restoreFile: RestoreFile)
}

public final class BackupRestoreRepositoryImp: BackupRestoreRepository {
    public init() {
        
    }

    // MARK: - Backup
    
    /// realm Object Type을 넣으면 백업 data를 만들어주는 함수
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
    
    /// backup이 필요한 Realm Object를 Data로 변경해 backup할 데이터를 json으로 저장하고, Data List를 반환하는 함수
    public func backUp() -> [Data] {
        print("DiaryRepo :: backup!")
        var backupDataArr: [Data] = []
        var backupDataDic: [String: Data] = [:]
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        // 각 데이터가 있을 경우에 리스트/ 딕셔너리에 할당
        if let diaryData = makeBackupData(of: DiaryModelRealm.self) {
            backupDataDic["diary"] = diaryData
            backupDataArr.append(diaryData)
        }
        if let momentsData = makeBackupData(of: MomentsRealm.self) {
            backupDataDic["moments"] = momentsData
            backupDataArr.append(momentsData)
        }
        if let tempSaveData = makeBackupData(of: TempSaveModelRealm.self) {
            backupDataDic["tempSave"] = tempSaveData
            backupDataArr.append(tempSaveData)
        }
        if let diarySearchData = makeBackupData(of: DiarySearchModelRealm.self) {
            backupDataDic["diarySearch"] = diarySearchData
            backupDataArr.append(diarySearchData)
        }
        if let passwordData = makeBackupData(of: PasswordModelRealm.self) {
            backupDataDic["password"] = passwordData
            backupDataArr.append(passwordData)
        }

        // 딕셔너리에 있는 Key값은 파일의 이름
        // value는 data로 FileManager에 json파일 저장
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
    
    public func addOrUpdateBackupHistory() {
        guard let realm = Realm.safeInit() else { return }
        
        
        let diaryModelRealm = realm.objects(DiaryModelRealm.self)
            .toArray(type: DiaryModelRealm.self)
            .sorted { $0.createdAt < $1.createdAt }
            .filter { $0.isDeleted == false }
        
        let date: Date = Date()
        let diaryCount: Int = diaryModelRealm.count
        let diaryPageCount: Int = diaryModelRealm.first?.pageNum ?? 0
        
        if let backupHistory = realm.objects(BackupHistoryModelRealm.self).first {
            realm.safeWrite {
                backupHistory.createdAt = date
                backupHistory.diaryCount = diaryCount
                backupHistory.pageCount = diaryPageCount
            }
        } else {
            let backupHistory = BackupHistoryModelRealm(pageCount: diaryPageCount,
                                                        diaryCount: diaryCount,
                                                        createdAt: date
            )
            realm.safeWrite {
                realm.add(backupHistory)
            }
        }
    }
    
    // MARK: - Restore
    
    /// RealmObject를 넣으면 decode한 realm Array를 반환
    public func makeRestoreData<T: Object & Codable>(of: T.Type, data: Data?) -> [T]? {
        // 데이터가 nil로 들어왔을 경우 restoreFile을 만들 필요가 없으므로 nil 리턴
        guard let data = data else { return nil }
        let decoder = JSONDecoder()
        
        guard let array = try? decoder.decode([T].self, from: data) else { return nil }
        return array
    }
    
    /// 복원 하기전에 이미 있는 이미지를 삭제하는 함수
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

    /// 최종적으로 json파일을 기반으로 realm.default에 할당하는 작업
    public func restoreWithJson(restoreFile: RestoreFile) {
        print("DiaryRepo :: restoreWithJson! restoreFile = \(restoreFile)")
        guard let realm = Realm.safeInit() else {
            return
        }
        /// DiaryData

        if let diaryArray = makeRestoreData(of: DiaryModelRealm.self, data: restoreFile.diaryData) {
            restoreWithJsonSaveImageData(diaryModelRealm: diaryArray, imageFiles: restoreFile.imageDataArr)
            deleteDiaries()
            
            realm.safeWrite {
                realm.add(diaryArray)
            }
        }
        
        if let moments = makeRestoreData(of: MomentsRealm.self, data: restoreFile.momentsData)?.first {
            restoreMoments(newMoments: moments)
        }
        
        if let password = makeRestoreData(of: PasswordModelRealm.self, data: restoreFile.passwordData)?.first {
            restorePassword(newPassword: password)
        }
        
        if let tempSave = makeRestoreData(of: TempSaveModelRealm.self, data: restoreFile.tempSaveData) {
            restoreTempSave(newTempSave: tempSave)
        }
    }
    
    /// Moments 데이터를 복원하는 함수
    public func restoreMoments(newMoments: MomentsRealm) {
        guard let realm = Realm.safeInit() else { return }
        guard let moments = realm.objects(MomentsRealm.self).first else { return }
        
        realm.safeWrite {
            moments.itemsArr = newMoments.itemsArr
            moments.onboardingIsClear = newMoments.onboardingIsClear
            moments.onboardingClearDate = newMoments.onboardingClearDate
            moments.lastUpdatedDate = newMoments.lastUpdatedDate
        }
    }
    
    /// password를 복원하는 함수
    public func restorePassword(newPassword: PasswordModelRealm) {
        guard let realm = Realm.safeInit() else { return }
        // password가 있을 경우
        if let password = realm.objects(PasswordModelRealm.self).first {
            realm.safeWrite {
                password.isEnabled = newPassword.isEnabled
                password.password = newPassword.password
            }
        }
        // password가 없을 경우 새로 만들어주어야 함
        else {
            realm.safeWrite {
                realm.add(newPassword)
            }
        }
    }
    
    /// tempSave를 복원하는 함수
    public func restoreTempSave(newTempSave: [TempSaveModelRealm]) {
        guard let realm = Realm.safeInit() else { return }
        let tempSave = realm.objects(TempSaveModelRealm.self)
        
        realm.safeWrite {
            realm.delete(tempSave)
            realm.add(newTempSave)
        }
        
    }
    
    /// 다이어리에 저장된 이미지, 검색, 리마인더 등 데이터를 삭제하는 함수
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
    
    /// Realm의 ObjectID가 변환되기 때문에,
    /// 변환된 ObjectID에 맞게 이미지를 저장할 수 있도록 하는 함수
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