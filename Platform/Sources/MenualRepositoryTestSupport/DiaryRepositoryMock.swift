//
//  DiaryRepositoryMock.swift
//  
//
//  Created by 정진균 on 2023/02/05.
//

import Foundation
import RxSwift
import RxRelay
import MenualEntity
import MenualRepository
//
//public final class DiaryRepositoryMock: DiaryRepository {
//    public init() {
//
//    }
//
//    public var diaryString: RxRelay.BehaviorRelay<[MenualEntity.DiaryModelRealm]>
//
//    public var filteredDiaryDic: RxRelay.BehaviorRelay<MenualEntity.DiaryHomeFilteredSectionModel?>
//
//    public var password: RxRelay.BehaviorRelay<MenualEntity.PasswordModelRealm?>
//
//    public var fetchCallCount = 0
//    public func fetch() {
//        fetchCallCount += 1
//    }
//
//    public func addDiary(info: MenualEntity.DiaryModelRealm) {
//
//    }
//
//    public func updateDiary(info: MenualEntity.DiaryModelRealm, uuid: String) {
//
//    }
//
//    public func updateDiary(DiaryModel: MenualEntity.DiaryModelRealm, reminder: MenualEntity.ReminderModelRealm?) {
//
//    }
//
//    public func hideDiary(isHide: Bool, info: MenualEntity.DiaryModelRealm) {
//
//    }
//
//    public func removeAllDiary() {
//
//    }
//
//    public func deleteDiary(info: MenualEntity.DiaryModelRealm) {
//
//    }
//
//    public func saveImageToDocumentDirectory(imageName: String, imageData: Data, completionHandler: @escaping (Bool) -> Void) {
//
//    }
//
//    public func deleteImageFromDocumentDirectory(diaryUUID: String, completionHandler: @escaping (Bool) -> Void) {
//
//    }
//
//    public func addReply(info: MenualEntity.DiaryReplyModelRealm, diaryModel: MenualEntity.DiaryModelRealm) {
//
//    }
//
//    public func deleteReply(diaryModel: MenualEntity.DiaryModelRealm, replyModel: MenualEntity.DiaryReplyModelRealm) {
//
//    }
//
//    public func addDiarySearch(info: MenualEntity.DiaryModelRealm) {
//
//    }
//
//    public func deleteAllRecentDiarySearch() {
//
//    }
//
//    public func deleteRecentDiarySearch(uuid: String) {
//
//    }
//
//    public func addTempSave(diaryModel: MenualEntity.DiaryModelRealm, tempSaveUUID: String) {
//
//    }
//
//    public func updateTempSave(diaryModel: MenualEntity.DiaryModelRealm, tempSaveUUID: String) {
//
//    }
//
//    public func deleteTempSave(uuidArr: [String]) {
//
//    }
//
//    public func filterDiary(weatherTypes: [MenualEntity.Weather], placeTypes: [MenualEntity.Place], isOnlyFilterCount: Bool) -> Int {
//        return 0
//    }
//
//    public func fetchPassword() {
//
//    }
//
//    public func addPassword(model: MenualEntity.PasswordModelRealm) {
//
//    }
//
//    public func updatePassword(password: Int, isEnabled: Bool) {
//
//    }
//
//
//}
