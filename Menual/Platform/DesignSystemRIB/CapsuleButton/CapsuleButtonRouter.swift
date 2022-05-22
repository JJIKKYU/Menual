//
//  CapsuleButtonRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs

protocol CapsuleButtonInteractable: Interactable {
    var router: CapsuleButtonRouting? { get set }
    var listener: CapsuleButtonListener? { get set }
}

protocol CapsuleButtonViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class CapsuleButtonRouter: ViewableRouter<CapsuleButtonInteractable, CapsuleButtonViewControllable>, CapsuleButtonRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: CapsuleButtonInteractable, viewController: CapsuleButtonViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
