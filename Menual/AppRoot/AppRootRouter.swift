//
//  AppRootRouter.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import RIBs

protocol AppRootInteractable: Interactable,
                                DiaryWritingListener
{
    var router: AppRootRouting? { get set }
    var listener: AppRootListener? { get set }
}

protocol AppRootViewControllable: ViewControllable {
    func setViewController(_ viewController: ViewControllable)
}

final class AppRootRouter: LaunchRouter<AppRootInteractable, AppRootViewControllable>, AppRootRouting {
    
    private let diaryWriting: DiaryWritingBuildable
    
    private var diaryWritingRouting: ViewableRouting?
    
    init(
        interactor: AppRootInteractable,
        viewController: AppRootViewControllable,
        diaryWriting: DiaryWritingBuildable
    ) {
        self.diaryWriting = diaryWriting
        
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    override func didLoad() {
        attachMainHome()
    }
    
    func attachMainHome() {
        let diaryWritingRouting = diaryWriting.build(withListener: interactor)
        
        attachChild(diaryWritingRouting)
        
        // viewController가 많아지면 여기에 추가해서 진행
        let viewControllers = [
            NavigationControllerable(root: diaryWritingRouting.viewControllable)
        ]
        
        viewController.setViewController(diaryWritingRouting.viewControllable)
    }
    
    func cleanupViews() {
        // TODO: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.
    }

}
