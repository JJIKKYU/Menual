//
//  DesignSystemRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import RIBs

protocol DesignSystemInteractable: Interactable, BoxButtonListener {
    var router: DesignSystemRouting? { get set }
    var listener: DesignSystemListener? { get set }
}

protocol DesignSystemViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DesignSystemRouter: ViewableRouter<DesignSystemInteractable, DesignSystemViewControllable>, DesignSystemRouting {

    private let boxButtonBuildable: BoxButtonBuildable
    private var boxButtonRouting: Routing?
    
    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DesignSystemInteractable,
        viewController: DesignSystemViewControllable,
        boxButtonBuildable: BoxButtonBuildable
    ) {
        self.boxButtonBuildable = boxButtonBuildable
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
        print("detachBoxButtonVC, isOnlyDetach = \(isOnlyDetach)")

        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }

        detachChild(router)
        boxButtonRouting = nil
    }
}
