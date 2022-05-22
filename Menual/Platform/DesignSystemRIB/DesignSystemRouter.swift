//
//  DesignSystemRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import RIBs

protocol DesignSystemInteractable: Interactable, BoxButtonListener, GNBHeaderListener, ListHeaderListener {
    var router: DesignSystemRouting? { get set }
    var listener: DesignSystemListener? { get set }
}

protocol DesignSystemViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DesignSystemRouter: ViewableRouter<DesignSystemInteractable, DesignSystemViewControllable>, DesignSystemRouting {


    private let boxButtonBuildable: BoxButtonBuildable
    private var boxButtonRouting: Routing?
    
    private let gnbHeaderBuildable: GNBHeaderBuildable
    private var gnbHeaderRouting: Routing?
    
    private let listHeaderBuildable: ListHeaderBuildable
    private var listHeaderRouting: Routing?
    
    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DesignSystemInteractable,
        viewController: DesignSystemViewControllable,
        boxButtonBuildable: BoxButtonBuildable,
        gnbHeaderBuildable: GNBHeaderBuildable,
        listHeaderBuildable: ListHeaderBuildable
    ) {
        self.boxButtonBuildable = boxButtonBuildable
        self.gnbHeaderBuildable = gnbHeaderBuildable
        self.listHeaderBuildable = listHeaderBuildable
        super.init(interactor: interactor,
                   viewController: viewController
        )
        interactor.router = self
    }
    
    // MARK: - Box Button DesignSystem RIBs
    func attachBoxButtonVC() {
        if boxButtonRouting != nil {
            return
        }
        
        let router = boxButtonBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        boxButtonRouting = router
        attachChild(router)
    }
    
    func detachBoxButtonVC(isOnlyDetach: Bool) {
        guard let router = boxButtonRouting else {
            return
        }

        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }

        detachChild(router)
        boxButtonRouting = nil
    }
    
    // MARK: - GNB Header DesignSystem RIBs
    func attachGnbHeaderVC() {
        if gnbHeaderRouting != nil {
            return
        }
        
        let router = gnbHeaderBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        gnbHeaderRouting = router
        attachChild(router)
    }
    
    func detachGnbHeaderVC(isOnlyDetach: Bool) {
        guard let router = gnbHeaderRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        gnbHeaderRouting = nil
    }
    
    // MARK: - List Header DesignSystem RIBs
    func attachListHeaderVC() {
        if listHeaderRouting != nil {
            return
        }
        
        let router = listHeaderBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        listHeaderRouting = router
        attachChild(router)
    }
    
    func detachListHeaderVC(isOnlyDetach: Bool) {
        guard let router = listHeaderRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        listHeaderRouting = nil
    }
}
