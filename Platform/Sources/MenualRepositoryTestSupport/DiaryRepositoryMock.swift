//
//  DiaryRepositoryMock.swift
//  
//
//  Created by 정진균 on 2023/02/05.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift
import MenualEntity
import MenualRepository

public final class DiaryRepositoryMock: DiaryRepository {
    public init() {

    }

    public var filteredDiaryDic: BehaviorRelay<DiaryHomeFilteredSectionModel?> = .init(value: nil)
    public var password: BehaviorRelay<PasswordModelRealm?> = .init(value: nil)

    public var addDiaryCallCount = 0
    public func addDiary(info: MenualEntity.DiaryModelRealm) {
        addDiaryCallCount += 1
    }
    
    public var updateDiaryCallCount1 = 0
    public func updateDiary(info: MenualEntity.DiaryModelRealm, uuid: String) {
        updateDiaryCallCount1 += 1
    }

    public var updateDiaryCallCount2 = 0
    public func updateDiary(DiaryModel: MenualEntity.DiaryModelRealm, reminder: MenualEntity.ReminderModelRealm?) {
        updateDiaryCallCount2 += 1
    }

    public var hideDiaryCallCount = 0
    public func hideDiary(isHide: Bool, info: MenualEntity.DiaryModelRealm) {
        hideDiaryCallCount += 1
    }
    
    public var removeDiaryCallCount = 0
    public func removeAllDiary() {
        removeDiaryCallCount += 1
    }

    public var deleteDiaryCallCount = 0
    public func deleteDiary(info: MenualEntity.DiaryModelRealm) {
        deleteDiaryCallCount += 1
    }

    public var saveImageToDocumentDirectoryCallCount = 0
    public func saveImageToDocumentDirectory(imageName: String, imageData: Data, completionHandler: @escaping (Bool) -> Void) {
        saveImageToDocumentDirectoryCallCount += 1
        completionHandler(true)
    }

    public var deleteImageFromDocumentDirectoryCallCount = 0
    public func deleteImageFromDocumentDirectory(diaryUUID: String, completionHandler: @escaping (Bool) -> Void) {
        deleteImageFromDocumentDirectoryCallCount += 1
        completionHandler(true)
    }

    public var addReplyCallCount = 0
    public func addReply(info: MenualEntity.DiaryReplyModelRealm, diaryModel: MenualEntity.DiaryModelRealm) {
        addReplyCallCount += 1
    }

    public var deleteReplyCallCount = 0
    public func deleteReply(diaryModel: MenualEntity.DiaryModelRealm, replyModel: MenualEntity.DiaryReplyModelRealm) {
        deleteReplyCallCount += 1
    }

    public var addDiarySearchCallCount = 0
    public func addDiarySearch(info: MenualEntity.DiaryModelRealm) {
        addDiarySearchCallCount += 1
    }

    public var deleteAllRecentDiarySearchCallCount = 0
    public func deleteAllRecentDiarySearch() {
        deleteAllRecentDiarySearchCallCount += 1
    }

    public var deleteRecentDiarySearchCallCount = 0
    public func deleteRecentDiarySearch(uuid: String) {
        deleteRecentDiarySearchCallCount += 1
    }

    public var addTempSaveCallCount = 0
    public func addTempSave(diaryModel: MenualEntity.DiaryModelRealm, tempSaveUUID: String) {
        addTempSaveCallCount += 1
    }

    public var updateTempSaveCallCount = 0
    public func updateTempSave(diaryModel: MenualEntity.DiaryModelRealm, tempSaveUUID: String) {
        updateTempSaveCallCount += 1
    }

    public var deleteTempSaveCallCount = 0
    public func deleteTempSave(uuidArr: [String]) {
        deleteTempSaveCallCount += 1
    }

    public var filterDiaryCallCount = 0
    public func filterDiary(weatherTypes: [MenualEntity.Weather], placeTypes: [MenualEntity.Place], isOnlyFilterCount: Bool) -> Int {
        filterDiaryCallCount += 1
        return 0
    }

    public var fetchPasswordCallCount = 0
    public func fetchPassword() {
        fetchPasswordCallCount += 1
    }

    public var addPasswordCallCount = 0
    public func addPassword(model: MenualEntity.PasswordModelRealm) {
        addPasswordCallCount += 1
    }

    public var updatePasswordCallCount = 0
    public func updatePassword(password: Int, isEnabled: Bool) {
        updatePasswordCallCount += 1
    }


}
