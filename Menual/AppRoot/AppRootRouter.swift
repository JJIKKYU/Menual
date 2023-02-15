//
//  AppRootRouter.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import RIBs
import RxRelay
import MenualUtil
import ProfilePassword
import DiaryHome
import Foundation

protocol AppRootInteractable: Interactable,
                              DiaryHomeListener,
                              ProfilePasswordListener,
                              SplashListener
{
    var router: AppRootRouting? { get set }
    var listener: AppRootListener? { get set }
}

protocol AppRootViewControllable: ViewControllable {
    func setViewController(_ viewController: ViewControllable)
}

final class AppRootRouter: LaunchRouter<AppRootInteractable, AppRootViewControllable>, AppRootRouting {
    
    var navigationController: NavigationControllerable?
    
    private let diaryHome: DiaryHomeBuildable
    private let profilePassword: ProfilePasswordBuildable
    
    private var registerHomeRouting: ViewableRouting?
    private var loginHomeRouting: ViewableRouting?
    private var diaryHomeRouting: ViewableRouting?
    private var profilePasswordRouting: ViewableRouting?
    private let diaryUUIDRelay: BehaviorRelay<String>
    
    private let splash: SplashBuildable
    private var splashRouting: ViewableRouting?
    
    init(
        interactor: AppRootInteractable,
        viewController: AppRootViewControllable,
        diaryHome: DiaryHomeBuildable,
        profilePassword: ProfilePasswordBuildable,
        diaryUUIDRelay: BehaviorRelay<String>,
        splash: SplashBuildable
    ) {
        self.diaryUUIDRelay = diaryUUIDRelay
        self.diaryHome = diaryHome
        self.profilePassword = profilePassword
        self.splash = splash
        
        super.init(interactor: interactor, viewController: viewController)

        interactor.router = self
    }
    
    override func didLoad() {
        // attachMainHome()
    }
    
    // Bottom Up 으로 스크린을 띄울때
    private func presentInsideNavigation(_ viewControllable: ViewControllable) {
        let navigation = NavigationControllerable(root: viewControllable)
        // navigation.navigationController.presentationController?.delegate = interactor.presentationDelegateProxy
        navigation.navigationController.isNavigationBarHidden = true
        navigation.navigationController.modalPresentationStyle = .fullScreen
        self.navigationController = navigation
        
        viewController.present(navigation, animated: true, completion:  nil)
    }
    
    private func dismissPresentedNavigation(completion: (() -> Void)?) {
        if self.navigationController == nil {
            return
        }
        
        viewController.dismiss(completion: nil)
        self.navigationController = nil
    }
    
    func attachMainHome() {
        // let registerIDRouting = registerID.build(withListener: interactor)
        let diaryHomeRouting = diaryHome.build(
            withListener: interactor,
            diaryUUIDRelay: nil
        )
        attachChild(diaryHomeRouting)
        
        let navigation = NavigationControllerable(root: diaryHomeRouting.viewControllable)
        navigation.navigationController.modalPresentationStyle = .fullScreen
//        navigation.navigationController.navigationBar.backgroundColor = .clear
//        navigation.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .top, barMetrics: .default)
//        navigation.navigationController.navigationBar.shadowImage = UIImage()
//        navigation.navigationController.navigationBar.barTintColor = .red
//        navigation.navigationController.navigationBar.tintColor = .white
//        navigation.navigationController.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 25), .foregroundColor: UIColor.red]
//        navigation.navigationController.title = "xkdlxmffj"
//        diaryHomeRouting.viewControllable.uiviewController.title = "123123"
        
        //viewController.setViewController(diaryWritingRouting.viewControllable)
//        navigation.present(splashRouting.viewControllable, animated: false) {
//            print("!!!?")
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
//                print("!@#")
//            }
//        }
        
         viewController.setViewController(navigation)
        
    }
    
    func cleanupViews() {
        // TODO: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.
    }
    
    func detachProfilePassword() {
        print("AppRoot :: detachProfilePassword!")
        
        guard let router = profilePasswordRouting else {
            return
        }
        
        // viewController.popViewController(animated: true)
//        let diaryHomeRouting = diaryHome.build(withListener: interactor)
//        attachChild(diaryHomeRouting)
//        self.navigationController?.pushViewController(diaryHomeRouting.viewControllable, animated: true)
        // self.navigationController?.popViewController(animated: true)
        navigationController?.dismiss(completion: nil)

        detachChild(router)
        profilePasswordRouting = nil
    }
    
    func attachProfilePassword() {
        print("AppRoot :: attachProfilePassword!")
        
        let profilePasswordRouting = profilePassword.build(
            withListener: interactor,
            isMainScreen: true,
            isPasswordChange: false,
            isPaswwordDisabled: false
        )
        self.profilePasswordRouting = profilePasswordRouting
        attachChild(profilePasswordRouting)
        
        let diaryHomeRouting = diaryHome.build(
            withListener: interactor,
            diaryUUIDRelay: self.diaryUUIDRelay
        )
        attachChild(diaryHomeRouting)
        
        let navigation = NavigationControllerable(root: diaryHomeRouting.viewControllable)
        navigationController = navigation
        
        navigation.navigationController.modalPresentationStyle = .fullScreen
        viewController.setViewController(navigation)
        
        // presentInsideNavigation(profilePasswordRouting.viewControllable)
        navigation.present(profilePasswordRouting.viewControllable, animated: false, completion: nil)
    }

}
