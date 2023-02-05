//
//  ProfileRestoreInteractor.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import RxSwift
import ZipArchive
import RealmSwift
import MenualUtil
import MenualEntity
import UserNotifications

public protocol ProfileRestoreRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

public protocol ProfileRestorePresentable: Presentable {
    var listener: ProfileRestorePresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

public protocol ProfileRestoreListener: AnyObject {
    func pressedProfileRestoreBackBtn(isOnlyDetach: Bool)
}

final class ProfileRestoreInteractor: PresentableInteractor<ProfileRestorePresentable>, ProfileRestoreInteractable, ProfileRestorePresentableListener {

    weak var router: ProfileRestoreRouting?
    weak var listener: ProfileRestoreListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: ProfileRestorePresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.pressedProfileRestoreBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    func restoreDiary(url: URL) {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let newPath = path + "/test2"
        
        print("ProfileRestore :: path = \(path), url = \(url.absoluteString), \(url.path)")
        SSZipArchive.unzipFile(atPath: url.path, toDestination: newPath) { _, _, c, d in
        
            print("ProfileRestore :: \(c) / \(d)")
        } completionHandler: { a, b, error in
            print("ProfileRestore :: \(a), \(b), error = \(error)")
        }

        // SSZipArchive.unzipFileAtPath(zipPath, toDestination: unzipPath)
        let realm = try? Realm(fileURL: URL(string: "\(newPath)/default.realm")!)
        let diaryModelRealm = realm?.objects(DiaryModelRealm.self)
        print("ProfileRestore :: 교체예정인 다이어리 개수 = \(diaryModelRealm?.count)")

        let config = Realm.Configuration(fileURL: URL(string: "\(newPath)/default.realm"))
        Realm.Configuration.defaultConfiguration = config
        print("ProfileRestore :: realm = \(realm)")
        print("ProfileRestore :: config = \(config)")
        restartAppWithPush()
    }
    
    func restartAppWithPush() {
        print("ProfileRestore :: restartAppWithPush!")
        // var localUserInfo: [AnyHashable : Any] = [:]
        // localUserInfo["pushType"] = "restart"
        
        let content = UNMutableNotificationContent()
        content.title = "Configuration Update Complete"
        content.body = "Tap to reopen the application"
        content.sound = UNNotificationSound.default
        // content.userInfo = localUserInfo
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.5, repeats: false)

        let identifier = UUID().uuidString
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        
        center.add(request) { error in
            print("ProfileRestore :: error? = \(error)")
        }
        exit(0)
    }
}
