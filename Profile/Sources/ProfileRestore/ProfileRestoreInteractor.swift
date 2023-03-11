//
//  ProfileRestoreInteractor.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import RxSwift
import RxRelay
import ZipArchive
import RealmSwift
import MenualUtil
import MenualEntity
import UserNotifications
import MenualRepository

public protocol ProfileRestoreRouting: ViewableRouting {
    func attachProfileConfirm(fileURL: URL?)
    func detachProfileConfirm(isOnlyDetach: Bool, isAnimated: Bool)
}

public protocol ProfileRestorePresentable: Presentable {
    var listener: ProfileRestorePresentableListener? { get set }
}

public protocol ProfileRestoreListener: AnyObject {
    func pressedProfileRestoreBackBtn(isOnlyDetach: Bool)
    func restoreSuccess()
}

public protocol ProfileRestoreInteractorDependency {
    var diaryRepository: DiaryRepository { get }
    var backupRestoreRepository: BackupRestoreRepository { get }
}

final class ProfileRestoreInteractor: PresentableInteractor<ProfileRestorePresentable>, ProfileRestoreInteractable, ProfileRestorePresentableListener {

    weak var router: ProfileRestoreRouting?
    weak var listener: ProfileRestoreListener?
    private let dependency: ProfileRestoreInteractorDependency
    
    private let disposeBag = DisposeBag()
    var fileName: String?
    var fileCreatedAt: String?

    init(
        presenter: ProfileRestorePresentable,
        dependency: ProfileRestoreInteractorDependency
    ) {
        self.dependency = dependency
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.pressedProfileRestoreBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedBackupBtn(url: URL?) {
        router?.attachProfileConfirm(fileURL: url)
    }
    
    func profileRestoreConfirmPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachProfileConfirm(isOnlyDetach: isOnlyDetach, isAnimated: true)
    }
    
    /// DiaryHome까지 restoreSucess 전달
    func restoreSuccess() {
        print("PRofileRestoreConfirm :: profileRestoreSuccess!")
        self.router?.detachProfileConfirm(isOnlyDetach: false, isAnimated: false)
        self.listener?.restoreSuccess()
    }
}
