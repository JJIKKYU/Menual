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
    func exitWithAnimation()
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

        // SSZipArchive.unzipFileAtPath(zipPath, toDestination: unzipPath)
        let realm = try? Realm(fileURL: URL(string: "\(newPath)/default.realm")!)
        let diaryModelRealm = realm?.objects(DiaryModelRealm.self)
        print("ProfileRestore :: 교체예정인 다이어리 개수 = \(diaryModelRealm?.count)")

        let config = Realm.Configuration(fileURL: URL(string: "\(newPath)/default.realm"))
        Realm.Configuration.defaultConfiguration = config
        print("ProfileRestore :: realm = \(realm)")
        print("ProfileRestore :: config = \(config)")
        // restartAppWithPush()
    }
    
    func clearDocumentFolder() {
        let fileManager = FileManager.default
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: path)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: path + "/" + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    func restartAppWithPush() {
        print("ProfileRestore :: restartAppWithPush!")
        // var localUserInfo: [AnyHashable : Any] = [:]
        // localUserInfo["pushType"] = "restart"
        
        let content = UNMutableNotificationContent()
        content.title = "메뉴얼 가져오기가 완료되었습니다👏"
        content.body = "터치해 앱을 다시 실행해주세요"
        // content.sound = UNNotificationSound.default
        // content.userInfo = localUserInfo
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let identifier = UUID().uuidString
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        
        center.add(request) { error in
            print("ProfileRestore :: error? = \(error)")
        }
        
        presenter.exitWithAnimation()
    }
}
