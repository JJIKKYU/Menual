//
//  AppRootRouter.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import RIBs

protocol AppRootInteractable: Interactable,
                                DiaryWritingListener, RegisterHomeListener
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
    // private let registerID: RegisterIDBuildable
    
    private var diaryWritingRouting: ViewableRouting?
    private var registerHomeRouting: ViewableRouting?
    // private let registerIDRouting: ViewableRouting?
    
    init(
        interactor: AppRootInteractable,
        viewController: AppRootViewControllable,
        diaryWriting: DiaryWritingBuildable,
        registerHome: RegisterHomeBuildable
       //  registerID: RegisterIDBuildable
    ) {
        // self.registerID = registerID
        self.diaryWriting = diaryWriting
        self.registerHome = registerHome
        // self.registerIDRouting = .none
        
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
        
        // attachChild(diaryWritingRouting)
        // attachChild(registerHomeRouting)
        attachChild(registerHomeRouting)
        
        // viewController가 많아지면 여기에 추가해서 진행
        /*
        let viewControllers = [
            NavigationControllerable(root: registerHomeRouting.viewControllable)
            // NavigationControllerable(root: diaryWritingRouting.viewControllable)
        ]
         */
        
        // let navigation = NavigationControllerable(root: registerHomeRouting.)
         // navigation.navigationController.modalPresentationStyle = .fullScreen
        
        //viewController.setViewController(diaryWritingRouting.viewControllable)
        // viewController.setViewController(navigation)
    }
    
    func cleanupViews() {
        // TODO: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.
    }

}
