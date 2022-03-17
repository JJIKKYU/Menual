//
//  AppRootRouter.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import RIBs

protocol AppRootInteractable: Interactable,
                                DiaryWritingListener,
                              RegisterHomeListener,
                              LoginHomeListener,
                              DiaryHomeListener
{
    var router: AppRootRouting? { get set }
    var listener: AppRootListener? { get set }
}

protocol AppRootViewControllable: ViewControllable {
    func setViewController(_ viewController: ViewControllable)
}

final class AppRootRouter: LaunchRouter<AppRootInteractable, AppRootViewControllable>, AppRootRouting {
    
    private let diaryWriting: DiaryWritingBuildable
    private let registerHome: RegisterHomeBuildable
    private let loginHome: LoginHomeBuildable
    private let diaryHome: DiaryHomeBuildable
    
    private var diaryWritingRouting: ViewableRouting?
    private var registerHomeRouting: ViewableRouting?
    private var loginHomeRouting: ViewableRouting?
    private var diaryHomeRouting: ViewableRouting?
    
    init(
        interactor: AppRootInteractable,
        viewController: AppRootViewControllable,
        diaryWriting: DiaryWritingBuildable,
        registerHome: RegisterHomeBuildable,
        loginHome: LoginHomeBuildable,
        diaryHome: DiaryHomeBuildable
    ) {
        self.diaryWriting = diaryWriting
        self.registerHome = registerHome
        self.loginHome = loginHome
        self.diaryHome = diaryHome
        
        super.init(interactor: interactor, viewController: viewController)

        interactor.router = self
    }
    
    override func didLoad() {
        attachMainHome()
    }
    
    func attachMainHome() {
        let registerHomeRouting = registerHome.build(withListener: interactor)
        // let registerIDRouting = registerID.build(withListener: interactor)
        let diaryWritingRouting = diaryWriting.build(withListener: interactor)
        let loginHomeRouting = loginHome.build(withListener: interactor)
        let diaryHomeRouting = diaryHome.build(withListener: interactor)
        
        // attachChild(diaryWritingRouting)
        // attachChild(registerHomeRouting)
        
        // attachChild(registerHomeRouting)
        // attachChild(loginHomeRouting)
        attachChild(diaryHomeRouting)
        
        // viewController가 많아지면 여기에 추가해서 진행
        /*
        let viewControllers = [
            NavigationControllerable(root: registerHomeRouting.viewControllable)
            // NavigationControllerable(root: diaryWritingRouting.viewControllable)
        ]
         */
        
         let navigation = NavigationControllerable(root: diaryHomeRouting.viewControllable)
         navigation.navigationController.modalPresentationStyle = .fullScreen
        navigation.navigationController.navigationBar.backgroundColor = .clear
        navigation.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .top, barMetrics: .default)
        navigation.navigationController.navigationBar.shadowImage = UIImage()
        navigation.navigationController.navigationBar.barTintColor = .red
        navigation.navigationController.navigationBar.tintColor = .white
        navigation.navigationController.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 25), .foregroundColor: UIColor.red]
        navigation.navigationController.title = "xkdlxmffj"
        diaryHomeRouting.viewControllable.uiviewController.title = "123123"
        
        //viewController.setViewController(diaryWritingRouting.viewControllable)
         viewController.setViewController(navigation)
    }
    
    func cleanupViews() {
        // TODO: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.
    }

}
