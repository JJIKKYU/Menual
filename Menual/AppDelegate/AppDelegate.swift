//
//  AppDelegate.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import UIKit
import RIBs
import Firebase
import FirebaseAnalytics
import RealmSwift
import RxRelay
import MenualEntity

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var launchRouter: LaunchRouting?
    private var urlHandler: URLHandler?
    private let diaryUUIDRelay = BehaviorRelay<String>(value: "")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        // 1. config 설정(이전 버전에서 다음 버전으로 마이그레이션될때 어떻게 변경될것인지)
        let config = Realm.Configuration(
            schemaVersion: 5, // 새로운 스키마 버전 설정
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion <= 2 {
                    // 1-1. 마이그레이션 수행(버전 2보다 작은 경우 버전 2에 맞게 데이터베이스 수정)
                    migration.enumerateObjects(ofType: MomentsItemRealm.className()) { oldObject, newObject in
                        newObject!["icon"] = "120px/book/open"
                    }
                }

                if oldSchemaVersion <= 3 {
                    migration.enumerateObjects(ofType: MomentsRealm.className()) { oldObject, newObject in
                        newObject!["onboardingClearDate"] = nil
                    }
                }
                
                if oldSchemaVersion <= 5 {
                    migration.enumerateObjects(ofType: MomentsRealm.className()) { oldObject, newObject in
                        newObject!["onboardingIsClear"] = false
                    }
                }
            }
        )
        
        // 2. Realm이 새로운 Object를 쓸 수 있도록 설정
        Realm.Configuration.defaultConfiguration = config
        
        let realm = Realm.safeInit()
         print("Realm Location = \(String(describing: realm?.configuration.fileURL))")
        
        print("AppDelegate :: 앱을 실행한다꿍")

        let component = AppComponent(diaryUUIDRelay: self.diaryUUIDRelay)
        let result = AppRootBuilder(dependency: component).build(diaryUUIDRelay: self.diaryUUIDRelay)
        self.launchRouter = result.launchRouter
        self.urlHandler = result.urlHandler
        
        launchRouter?.launch(from: window)
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
}

protocol URLHandler: AnyObject {
  func handle(_ url: URL)
}


// MARK: - Notification
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 앱이 foreground에 있을 때 push 알림이 오면 이 메서드가 호출된다.
        // diaryUUIDRelay.accept("diaryUUID!!!")
        completionHandler([.list, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // 사용자가 push 알림을 터치하면 이 메서드가 호출된다.

        // deep link 처리
        let userInfo = response.notification.request.content.userInfo
        print("Reminder :: url! = \(userInfo), \(userInfo["diaryUUID"])")

        guard let pushModel = try? PushModel(decoding: userInfo) else { return }
        
        diaryUUIDRelay.accept(pushModel.diaryUUID)
        print("Reminder :: pushModel = \(pushModel)")
    }
}
