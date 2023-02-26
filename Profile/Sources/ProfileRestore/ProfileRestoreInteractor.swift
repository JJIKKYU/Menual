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
    func detachProfileConfirm(isOnlyDetach: Bool)
}

public protocol ProfileRestorePresentable: Presentable {
    var listener: ProfileRestorePresentableListener? { get set }
    func exitWithAnimation()
}

public protocol ProfileRestoreListener: AnyObject {
    func pressedProfileRestoreBackBtn(isOnlyDetach: Bool)
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
    
    func restoreDiary(url: URL) {
        /*
        clearDocumentFolder()
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let newPath = path
        
        print("ProfileRestore :: path = \(path), url = \(url.absoluteString), \(url.path)")
        SSZipArchive.unzipFile(atPath: url.path, toDestination: newPath) { _, _, c, d in
        
            print("ProfileRestore :: \(c) / \(d)")
        } completionHandler: { a, b, error in
            print("ProfileRestore :: \(a), \(b), error = \(error)")
            self.restartAppWithPush()
        }
         */

        // SSZipArchive.unzipFileAtPath(zipPath, toDestination: unzipPath)
//        let realm = try? Realm(fileURL: URL(string: "\(newPath)/default.realm")!)
//        let diaryModelRealm = realm?.objects(DiaryModelRealm.self)
//        print("ProfileRestore :: 교체예정인 다이어리 개수 = \(diaryModelRealm?.count)")
//
//        let config = Realm.Configuration(fileURL: URL(string: "\(newPath)/default.realm"))
//        Realm.Configuration.defaultConfiguration = config
//        print("ProfileRestore :: realm = \(realm)")
//        print("ProfileRestore :: config = \(config)")
        // restartAppWithPush()
    }
    
    func pressedBackupBtn(url: URL?) {
        router?.attachProfileConfirm(fileURL: url)
    }
    
    func profileRestoreConfirmPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachProfileConfirm(isOnlyDetach: isOnlyDetach)
    }
}
