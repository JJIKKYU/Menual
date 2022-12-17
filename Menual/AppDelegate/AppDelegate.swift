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
        
        let realm = Realm.safeInit()
         print("Realm Location = \(String(describing: realm?.configuration.fileURL))")
        
        print("AppDelegate :: 앱을 실행한다꿍")

        let component = AppComponent(diaryUUIDRelay: self.diaryUUIDRelay)
        let result = AppRootBuilder(dependency: component).build(diaryUUIDRelay: self.diaryUUIDRelay)
        self.launchRouter = result.launchRouter
        self.urlHandler = result.urlHandler
        
        launchRouter?.launch(from: window)
        Analytics.logEvent("AppStart", parameters: nil)
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
