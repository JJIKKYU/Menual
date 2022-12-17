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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var launchRouter: LaunchRouting?
    private var urlHandler: URLHandler?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let realm = Realm.safeInit()
         print("Realm Location = \(String(describing: realm?.configuration.fileURL))")
        
        print("AppDelegate :: 앱을 실행한다꿍")

        let result = AppRootBuilder(dependency: AppComponent()).build()
        self.launchRouter = result.launchRouter
        self.urlHandler = result.urlHandler
        
        launchRouter?.launch(from: window)
        
        /*
        if #available(iOS 13.0, *){
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = .clear
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: "Montserrat-ExtraBold", size: 20)!]
            UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).standardAppearance = navBarAppearance
            UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).scrollEdgeAppearance =
         navBarAppearance
        }
         */
        
        Analytics.logEvent("AppStart", parameters: nil)
        
        // Realm
        
        /*
         // iceCream 코드
         
        syncEnigne = SyncEngine(objects: [
            SyncObject(type: DiaryModelRealm.self)
        ])
        application.registerForRemoteNotifications()
         */
        
        
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
        completionHandler([.list, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // 사용자가 push 알림을 터치하면 이 메서드가 호출된다.

        // deep link 처리
        let userInfo = response.notification.request.content.userInfo
        print("Reminder :: url! = \(userInfo), \(userInfo["diaryUUID"])")

        guard let pushModel = try? PushModel(decoding: userInfo) else { return }
        
        print("Reminder :: pushModel = \(pushModel)")
    }
}
