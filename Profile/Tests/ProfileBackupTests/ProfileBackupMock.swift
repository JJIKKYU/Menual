//
//  ProfileBackupMock.swift
//  
//
//  Created by 정진균 on 2023/03/12.
//

import Foundation
import ProfileBackup
import MenualEntity
import MenualRepository
import MenualRepositoryTestSupport
import RIBs
import RxRelay
import RxSwift

// MARK: - ProfileBackupPresentableMock
final class ProfileBackupPresentableMock: ProfileBackupPresentable {
    var listener: ProfileBackup.ProfileBackupPresentableListener?
    
    var showShareSheetParameters: (path: String, Void)?
    var showShareSheetCallCount = 0
    func showShareSheet(path: String) {
        showShareSheetCallCount += 1
        showShareSheetParameters = (path, ())
    }
    
    public var configueBackupHistoryUICallCount = 0
    func configueBackupHistoryUI() {
        configueBackupHistoryUICallCount += 1
    }
}

// MARK: - ProfileBackupDependencyMock
final class ProfileBackupDependencyMock: ProfileBackupDependency {
    var diaryRepository: DiaryRepository = DiaryRepositoryMock()
    var backupRestoreRepository: BackupRestoreRepository = BackupRestoreRepositoryMock()
}

// MARK: - ProfileBackupInteractorDependencyMock
final class ProfileBackupInteractorDependencyMock: ProfileBackupInteractorDependency {
    var diaryRepository: DiaryRepository = DiaryRepositoryMock()
    var backupRestoreRepository: BackupRestoreRepository = BackupRestoreRepositoryMock()
}

// MARK: - ProfileBackupListenerMock
final class ProfileBackupListenerMock: ProfileBackupListener {
    var pressedBackBtnParameters: (isOnlyDetach: Bool, Void)?
    var pressedProfileBackupBackBtnCallCount = 0
    func pressedProfileBackupBackBtn(isOnlyDetach: Bool) {
        pressedProfileBackupBackBtnCallCount += 1
        pressedBackBtnParameters = (isOnlyDetach, ())
    }
}

// MARK: - ProfileBackupBuildableMock
final class ProfileBackupBuildableMock: ProfileBackupBuildable {
    var buildHandler: ((_ listener: ProfileBackupListener) -> ProfileBackupRouting)?

    var buildCallCount = 0
    func build(withListener listener: ProfileBackup.ProfileBackupListener) -> ProfileBackupRouting {
        buildCallCount += 1
        
        if let buildHandler = buildHandler {
            return buildHandler(listener)
        }
        
        fatalError()
    }
}

// MARK: - ProfileBackupRoutingMock
final class ProfileBackupRoutingMock: ProfileBackupRouting {
    // Function Handler
    var loadHandler: (() -> ())?
    var loadCallCount: Int = 0
    var attachChildHandler: ((_ child: Routing) -> ())?
    var attachChildCallCount: Int = 0
    var detachChildHanlder: ((_ child: Routing) -> ())?
    var detachChildCallCount: Int = 0

    // Variable
    var viewControllable: RIBs.ViewControllable
    var interactableSetCallCount = 0
    var interactable: RIBs.Interactable {
        didSet { interactableSetCallCount += 1}
    }
    var childrenCallCount: Int = 0
    var children: [RIBs.Routing] = [Routing]() {
        didSet { childrenCallCount += 1 }
    }
    
    var lifecycleCallCount: Int = 0
    var lifecycle: RxSwift.Observable<RIBs.RouterLifecycle> {
        lifecycleRelay.asObservable()
    }
    private var lifecycleRelay = BehaviorRelay<RouterLifecycle>(value: .didLoad) {
        didSet { lifecycleCallCount += 1}
    }
    
    init(
        interactable: Interactable,
        viewControllable: ViewControllable
    ) {
        self.interactable = interactable
        self.viewControllable = viewControllable
    }
    
    func load() {
        loadCallCount += 1
        if let loadHandler = loadHandler {
            return loadHandler()
        }
    }
    
    func attachChild(_ child: RIBs.Routing) {
        attachChildCallCount += 1
        if let attachChildHandler = attachChildHandler {
            return attachChildHandler(child)
        }
    }
    
    func detachChild(_ child: RIBs.Routing) {
        detachChildCallCount += 1
        if let detachChildHanlder = detachChildHanlder {
            return detachChildHanlder(child)
        }
    }
}

// MARK: - ProfileBackupInteractableMock
final class ProfileBackupInteractableMock: ProfileBackupInteractable {
    var isActive: Bool { isActiveRelay.value }
    var isActiveStream: RxSwift.Observable<Bool> { isActiveRelay.asObservable() }
    private let isActiveRelay = BehaviorRelay<Bool>(value: false)
    
    var router: ProfileBackupRouting?
    var listener: ProfileBackupListener?

    func activate() {
        isActiveRelay.accept(true)
    }
    
    func deactivate() {
        isActiveRelay.accept(false)
    }
    
    var invokedCheckIsBackupEnabled = false
    func checkIsBackupEnabled() -> Bool {
        invokedCheckIsBackupEnabled = true
        return invokedCheckIsBackupEnabled
    }
 
    var tempZipPathString = "testTempPath"
    var tempZipPathCallCount = 0
    func tempZipPath() -> String {
        tempZipPathCallCount += 1
        return tempZipPathString
    }
    
    var saveZipCallCount = 0
    func saveZip() {
        saveZipCallCount += 1
    }
    
    var pressedBackBtnCallCount = 0
    var pressedBackBtnParameters: (isOnlyDetach: Bool, Void)?
    func pressedBackBtn(isOnlyDetach: Bool) {
        pressedBackBtnCallCount += 1
        pressedBackBtnParameters = (isOnlyDetach, ())
    }
    
    var addOrUpdateBackupHistoryCallCount = 0
    func addOrUpdateBackupHistory() {
        addOrUpdateBackupHistoryCallCount += 1
    }
}
