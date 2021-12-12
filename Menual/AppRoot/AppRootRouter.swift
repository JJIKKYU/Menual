//
//  AppRootRouter.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import RIBs

protocol AppRootInteractable: Interactable {
    var router: AppRootRouting? { get set }
    var listener: AppRootListener? { get set }
}

protocol AppRootViewControllable: ViewControllable {
    
}
//LaunchRouter<AppRootInteractable, AppRootViewControllable>
final class AppRootRouter: LaunchRouter<AppRootInteractable, AppRootViewControllable>, AppRootRouting {
    
    // TODO: Constructor inject child builder protocols to allow building children.
    override init(
        interactor: AppRootInteractable,
        viewController: AppRootViewControllable
    ) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func cleanupViews() {
        // TODO: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.
    }

}
