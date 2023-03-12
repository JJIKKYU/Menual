//
//  ProfileRestoreConfirmMock.swift
//  
//
//  Created by 정진균 on 2023/03/12.
//

import Foundation
import ProfileRestoreConfirm
import MenualEntity
import MenualRepository
import MenualRepositoryTestSupport
import RIBs
import RxRelay
import RxSwift

// MARK: - ProfileRestoreConfirmPresentableMock
final class ProfileRestoreConfirmPresentableMock: ProfileRestoreConfirmPresentable {
    var listener: ProfileRestoreConfirmPresentableListener?
    
    var notVaildZipFileCallCount = 0
    func notVaildZipFile() {
        notVaildZipFileCallCount += 1
    }
    
    var loadErrorZipFileCallCount = 0
    func loadErrorZipFile() {
        loadErrorZipFileCallCount += 1
    }
    
    var fileNameAndDateSetUICallCount = 0
    func fileNameAndDateSetUI() {
        fileNameAndDateSetUICallCount += 1
    }
}

// MARK: - ProfileRestoreConfirmDependencyMock
final class ProfileRestoreConfirmDependencyMock: ProfileRestoreConfirmDependency {
    var diaryRepository: DiaryRepository = DiaryRepositoryMock()
    var backupRestoreRepository: BackupRestoreRepository = BackupRestoreRepositoryMock()
}

// MARK: - ProfileRestoreConfirmInteractorDependencyMock
final class ProfileRestoreConfirmInteractorDependencyMock: ProfileRestoreConfirmInteractorDependency {
    var diaryRepository: DiaryRepository = DiaryRepositoryMock()
    var backupRestoreRepository: BackupRestoreRepository = BackupRestoreRepositoryMock()
}

// MARK: - ProfileRestoreConfirmListenerMock
final class ProfileRestoreConfirmListenerMock: ProfileRestoreConfirmListener {
    
    var profileRestoreConfirmPressedBackBtnCallCount = 0
    var profileRestoreConfirmPressedBackBtnParameter: (isOnlyDetach: Bool, Void)?
    func profileRestoreConfirmPressedBackBtn(isOnlyDetach: Bool) {
        profileRestoreConfirmPressedBackBtnCallCount += 1
        profileRestoreConfirmPressedBackBtnParameter = (isOnlyDetach, ())
    }
    
    var restoreSuccessCallCount = 0
    func restoreSuccess() {
        restoreSuccessCallCount += 1
    }
}

// MARK: - ProfileRestoreConfirmBuildableMock
final class ProfileRestoreConfirmBuildableMock: ProfileRestoreConfirmBuildable {
    var buildHandler: ((_ listener: ProfileRestoreConfirmListener) -> ProfileRestoreConfirmRouting)?

    var buildCallCount = 0
    func build(withListener listener: ProfileRestoreConfirmListener, fileURL: URL?) -> ProfileRestoreConfirmRouting {
        buildCallCount += 1
        
        if let buildHandler = buildHandler {
            return buildHandler(listener)
        }
        
        fatalError()
    }
}

// MARK: - ProfileRestoreConfirmRoutingMock
final class ProfileRestoreConfirmRoutingMock: ProfileRestoreConfirmRouting {
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

// MARK: - ProfileRestoreConfirmInteractableMock
final class ProfileRestoreConfirmInteractableMock: ProfileRestoreConfirmInteractable {
    var isActive: Bool { isActiveRelay.value }
    var isActiveStream: RxSwift.Observable<Bool> { isActiveRelay.asObservable() }
    private let isActiveRelay = BehaviorRelay<Bool>(value: false)

    var router: ProfileRestoreConfirmRouting?
    var listener: ProfileRestoreConfirmListener?
    
    func activate() {
        isActiveRelay.accept(true)
    }
    
    func deactivate() {
        isActiveRelay.accept(false)
    }
}
