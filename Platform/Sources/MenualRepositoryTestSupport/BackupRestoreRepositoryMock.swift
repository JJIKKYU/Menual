//
//  BackupRestoreRepositoryMock.swift
//  
//
//  Created by 정진균 on 2023/03/12.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift
import MenualEntity
import MenualRepository
import Realm

public final class BackupRestoreRepositoryMock: BackupRestoreRepository {
    
    public init() {
        
    }
    
    public var backUpCallCount: Int = 0
    public func backUp() -> [String: Data] {
        backUpCallCount += 1
        return [:]
    }
    
    public var isRestoring: Bool = false
    
    public var addOrUpdateBackupHistoryCallCount: Int = 0
    public func addOrUpdateBackupHistory() {
        addOrUpdateBackupHistoryCallCount += 1
    }
    
    public var restoreWithJsonSaveImageDataCallCount: Int = 0
    public func restoreWithJsonSaveImageData(diaryModelRealm: [MenualEntity.DiaryModelRealm], imageFiles: [MenualEntity.ImageFile]) {
        restoreWithJsonSaveImageDataCallCount += 1
    }
    
    public var restoreWithJsonCallCount: Int = 0
    public func restoreWithJson(restoreFile: MenualEntity.RestoreFile, progressRelay: RxRelay.BehaviorRelay<CGFloat>) {
        restoreWithJsonCallCount += 1
    }
    
    public var clearCacheDirecotryCallCount: Int = 0
    public func clearCacheDirecotry(completion: @escaping (Bool) -> Void) {
        clearCacheDirecotryCallCount += 1
        completion(true)
    }
    
    public var clearRestoreJsonCallCount: Int = 0
    public func clearRestoreJson(completion: @escaping (Bool) -> Void) {
        clearRestoreJsonCallCount += 1
        completion(true)
    }
}
